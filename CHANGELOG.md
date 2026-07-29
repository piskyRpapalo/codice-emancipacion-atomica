# Changelog

Formato: qué cambió y **por qué**. Este registro es deliberadamente público: es el
andamio cayendo a la vista. Un manifiesto que corrige sus propios errores en abierto
es más creíble que uno que finge no haberlos tenido.

## v1.0 · 2026-07-29

Primera versión publicada. Los cambios respecto al borrador privado son correcciones
de fondo, no de estilo:

- **Afirmación TRNG cortada (era falsa), y su primer reemplazo también.** El borrador
  afirmaba que el carbono es el único generador de aleatoriedad (TRNG). Es falso: existen
  TRNG de hardware (ruido térmico, osciladores en anillo, decaimiento radiactivo, RNG
  cuántico) que superan al humano. Un primer arreglo lo reencuadró como "entropía/teleología
  situada (S-TRNG)"; ese término también se **descarta**, porque nombrar "entropía" lo que
  hace a un dato *no* aleatorio invierte la afirmación y la expone a un defeater trivial (un
  modelo mejor la llevaría a cero). PARTE I se reescribe como **Anclaje del Carbono**: el
  nodo de carbono no aporta entropía, aporta tres propiedades que ningún generador de ruido
  tiene — información mutua con un marco inaccesible, costosidad infalsificable (Szabo,
  Zahavi) y **asunción de consecuencia** (soportar el coste de estar equivocado). Es esta
  última, no la aleatoriedad, la que ancla IronClaw.

- **Cláusula del 99.9% eliminada (era una puerta trasera en IronClaw).** El borrador
  incluía una "Paradoja de Optimización II" con "Decibelios de Supervivencia" que
  permitía a la máquina saltarse la firma humana bajo umbral cuantificado. Eso es una
  excepción a IronClaw, y IronClaw no admite excepción. Se sustituye por una línea
  explícita: **la firma humana no tiene umbral de omisión.**

- **PoW despublicado (violaba honest sensors).** El borrador mostraba hashes truncados
  decorativos (`3b9d…`, `e5a1…`) sin dato crudo detrás. Un hash sin su dato es teatro.
  Se eliminan todos y se sustituyen por un enlace a [`proofs/`](proofs/) y la nota
  **NO DATA**. `proofs/verify_pow.sh` hace cumplir la regla: sin dato, no hay hash.

- **Corrección criptográfica: HMAC → triple.** El borrador decía `ALGORITHM: HMAC-SHA256`.
  HMAC requiere clave compartida y no permite verificación pública. Se sustituye por el
  triple **SHA-256** (integridad) + **Ed25519** (autoría) + **OpenTimestamps** (precedencia).

- **"Inmutable" → versionado y refutable.** Se elimina toda pretensión de inmutabilidad
  o canonización. El estado es *Vivo. Versionado. Refutable.* Se añade la sección
  **Condiciones de Refutación**: qué evidencia obligaría a revisar cada Parte. PARTE III,
  que no admite refutación empírica, se marca explícitamente como **axioma declarado**.

- **PII: fecha de nacimiento eliminada** del encabezado de autoría. Solo queda el nombre.

- **Infraestructura de verificación añadida.** `verify_pow.sh` (verificador real del
  triple, con NO DATA→exit 0 y SKIP ruidoso de OpenTimestamps), el esquema de manifiesto
  con `intent`/`claims`/`does_not_claim` obligatorios, y CI (`.github/workflows/verify.yml`)
  que somete las pruebas a la misma disciplina que el código.
