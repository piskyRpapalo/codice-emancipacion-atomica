#!/usr/bin/env bash
# verify_pow.sh — Verificador de las pruebas del Códice de Emancipación Atómica.
#
# Triple de verificación pública (NO HMAC — HMAC exige clave compartida):
#   SHA-256        integridad del dato crudo (coreutils: sha256sum)
#   Ed25519        autoría del manifiesto    (ssh-keygen -Y verify)
#   OpenTimestamps precedencia temporal      (ots verify — opcional, SKIP ruidoso)
#
# Doctrina del repo (honest sensors): si no hay dato crudo, NO DATA y exit 0.
# Un repo sin pruebas es honesto; un repo con pruebas rotas NO lo es → exit != 0.
#
# Dependencias: bash, coreutils (sha256sum, awk, tr), ssh-keygen. `ots` opcional.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"                                  # trabaja desde proofs/
RAW="raw"
ALLOWED="pubkeys/allowed_signers"
NAMESPACE="codice-emancipacion-atomica"

fail() { echo "FAIL: $*" >&2; exit 1; }

# ── NO DATA: sin manifiestos publicados, el repo es honesto y sale 0 ──────────
shopt -s nullglob
manifests=("$RAW"/*.json)
if [ "${#manifests[@]}" -eq 0 ]; then
  echo "NO DATA — 0 pruebas publicadas (proofs/raw/ vacío). Honesto por diseño."
  exit 0
fi

# Hay pruebas: exigimos las herramientas y firmantes reales.
command -v sha256sum >/dev/null 2>&1 || fail "sha256sum no disponible (coreutils)."
command -v ssh-keygen >/dev/null 2>&1 || fail "ssh-keygen no disponible."
[ -f "$ALLOWED" ] || fail "falta $ALLOWED (firmantes permitidos)."
grep -qE '^[^#[:space:]].*ssh-ed25519 ' "$ALLOWED" \
  || fail "$ALLOWED no contiene ninguna clave ssh-ed25519 real: no se pueden verificar firmas."

verificadas=0
for m in "${manifests[@]}"; do
  echo "== $m =="
  # Aplana el JSON a una línea para grepear campos (schema controlado, sin jq).
  flat="$(tr '\n' ' ' < "$m" | tr -s ' ')"

  # 1) Campos de DOCTRINA obligatorios: intent / claims / does_not_claim.
  #    intent = teleología; does_not_claim = NO DATA hecho schema.
  echo "$flat" | grep -qE '"intent"[[:space:]]*:[[:space:]]*"[^"]+"' \
    || fail "$m: 'intent' ausente o vacío (la teleología es obligatoria)."
  echo "$flat" | grep -qE '"claims"[[:space:]]*:[[:space:]]*\[[[:space:]]*"' \
    || fail "$m: 'claims' ausente o vacío."
  echo "$flat" | grep -qE '"does_not_claim"[[:space:]]*:[[:space:]]*\[[[:space:]]*"' \
    || fail "$m: 'does_not_claim' ausente o vacío (NO DATA es obligatorio)."

  # 2) SHA-256: recomputa el CSV referenciado y compara con data_sha256.
  data_file="$(echo "$flat" | grep -oE '"data_file"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/')"
  data_sha="$(echo "$flat"  | grep -oE '"data_sha256"[[:space:]]*:[[:space:]]*"[0-9a-fA-F]{64}"' | head -1 | sed -E 's/.*"([0-9a-fA-F]{64})".*/\1/')"
  [ -n "$data_file" ] || fail "$m: falta 'data_file'."
  [ -n "$data_sha" ]  || fail "$m: falta 'data_sha256' válido (64 hex)."
  [ -f "$data_file" ] || fail "$m: no existe el fichero de datos '$data_file'."
  actual="$(sha256sum "$data_file" | awk '{print $1}')"
  if [ "$actual" != "$(printf '%s' "$data_sha" | tr 'A-F' 'a-f')" ]; then
    fail "$m: SHA-256 NO coincide. esperado=$data_sha  actual=$actual"
  fi
  echo "  SHA-256 OK  ($data_file)"

  # 3) Ed25519: firma detached del manifiesto (autoría). Descubre el firmante en
  #    allowed_signers y verifica el sobre firmado.
  sig="$m.sig"
  [ -f "$sig" ] || fail "$m: falta la firma Ed25519 '$sig'."
  principal="$(ssh-keygen -Y find-principals -f "$ALLOWED" -s "$sig" < "$m" 2>/dev/null | head -1 || true)"
  [ -n "$principal" ] || fail "$m: ninguna clave de $ALLOWED firma esta prueba."
  ssh-keygen -Y verify -f "$ALLOWED" -I "$principal" -n "$NAMESPACE" -s "$sig" < "$m" >/dev/null \
    || fail "$m: firma Ed25519 INVÁLIDA."
  echo "  Ed25519 OK  (firmante: $principal)"

  # 4) OpenTimestamps: precedencia (opcional). Si no hay 'ots', SKIP RUIDOSO.
  ots="$m.ots"
  if [ -f "$ots" ]; then
    if command -v ots >/dev/null 2>&1; then
      ots verify "$ots" >/dev/null 2>&1 \
        && echo "  OpenTimestamps OK" \
        || fail "$m: OpenTimestamps NO verifica."
    else
      echo "  SKIP RUIDOSO: 'ots' no instalado — precedencia OpenTimestamps NO verificada para $m."
    fi
  else
    echo "  (sin .ots — este manifiesto no reclama precedencia temporal)"
  fi

  verificadas=$((verificadas + 1))
done

echo "OK — ${verificadas} prueba(s) verificada(s)."
