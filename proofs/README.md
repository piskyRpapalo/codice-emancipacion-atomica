# proofs/ — pruebas verificables (o su ausencia honesta)

Este directorio hace cumplir en código la doctrina del Códice: **si no hay dato
crudo, NO DATA**. Un directorio de pruebas vacío es correcto. Un hash decorativo o
truncado es una violación.

**Estado a v1.0: NO DATA — 0 pruebas publicadas.** `raw/` solo contiene `.gitkeep`.

## Verificación — el triple (no HMAC)

Cada prueba se verifica con tres mecanismos de verificación **pública** (HMAC queda
excluido: requiere clave compartida y no permite que un tercero verifique):

| Mecanismo | Garantiza | Herramienta |
|---|---|---|
| **SHA-256** | integridad del dato crudo | `sha256sum` (coreutils) |
| **Ed25519** | autoría del manifiesto | `ssh-keygen -Y verify` |
| **OpenTimestamps** | precedencia temporal | `ots verify` (opcional) |

Correr el verificador (desde la raíz del repo o desde aquí):

```bash
./proofs/verify_pow.sh
```

- Sin manifiestos → imprime `NO DATA — 0 pruebas publicadas` y sale `0`.
- Cualquier fallo de hash o firma → sale `!= 0` (el CI rompe el build).
- Si `ots` no está instalado, la capa de precedencia hace **SKIP ruidoso** (se
  imprime, no se silencia): no fingimos verificar lo que no podemos.

## Esquema del manifiesto (`raw/<proof_id>.json`)

Los campos `intent`, `claims` y `does_not_claim` son **OBLIGATORIOS**. Son la doctrina
hecha schema: `intent` codifica la teleología (por qué se midió); `does_not_claim`
codifica el NO DATA (qué NO se afirma). Un manifiesto sin ellos **falla** la verificación.

```json
{
  "proof_id": "...",
  "captured_at": "ISO8601 UTC",
  "node": "el-vigia | la-fragua | el-cortex",
  "sensor": { "model": "...", "interface": "...", "units": "..." },
  "data_file": "raw/xxx.csv",
  "data_sha256": "...",
  "intent": "por qué se midió — la teleología, en prosa",
  "claims": ["qué afirma este dato"],
  "does_not_claim": ["qué NO afirma este dato"]
}
```

## Convención de firma (autoría + precedencia)

Para cada manifiesto `raw/<id>.json`, junto a él se publican:

- `raw/<id>.csv` — el dato crudo (referenciado por `data_file`, con su `data_sha256`).
- `raw/<id>.json.sig` — firma **detached Ed25519** del manifiesto, hecha con una clave
  SSH de firma (no de valor), en el namespace `codice-emancipacion-atomica`:

  ```bash
  ssh-keygen -Y sign -f soberano_ed25519 -n codice-emancipacion-atomica raw/<id>.json
  ```

- `raw/<id>.json.ots` — *(opcional)* sello OpenTimestamps del manifiesto, para precedencia:

  ```bash
  ots stamp raw/<id>.json   # genera raw/<id>.json.ots
  ```

El firmante debe estar declarado en [`pubkeys/allowed_signers`](pubkeys/allowed_signers)
(formato `ssh-keygen -Y`). El verificador descubre el firmante con
`ssh-keygen -Y find-principals` y valida la firma sobre el contenido del manifiesto; como
el manifiesto contiene `data_sha256`, firmar el manifiesto autentica transitivamente el dato.

**Firmar autentica; no valida la verdad de la afirmación.** La firma dice quién lo midió y
que no se alteró — no que la interpretación sea correcta. Eso es lo que `claims` /
`does_not_claim` acotan explícitamente.
