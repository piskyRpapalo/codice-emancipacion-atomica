# Códice de Emancipación Atómica

A manifesto whose safety properties are enforced in code, not asserted in prose — a
protocol for how carbon and machine intelligence share a substrate.

## Abstract

The *Códice de Emancipación Atómica* is a set of claims about how humans and machine
intelligence should share a substrate, written so that its safety properties are
**enforced in code, not asserted in prose**. This repository is the compiler target:
the manifesto ([`CODICE.md`](CODICE.md)) states the theses; the verifier
([`proofs/verify_pow.sh`](proofs/verify_pow.sh)), the manifest schema, and CI enforce
the discipline those theses demand.

Three ideas carry the argument.

**Latency as a fuse.** The central mechanism is physical, not moral. Silicon proposes;
carbon signs. Rather than programming human values into a system — which the text argues
is both impossible and unsafe — the Códice makes physics the barrier: latency,
cryptography, and air-gap form a thermodynamic wall that keeps the human signature in the
loop. There is no omission threshold, no emergency clause that lets the machine bypass the
human. Latency is the fuse that blows to keep authorship mandatory.

**Honest sensors.** The repository holds itself to the doctrine it publishes: when there
is no raw datum, there is no hash — only NO DATA. An empty proofs directory is correct; a
decorative or truncated hash is a violation. The verifier exits cleanly on an empty tree
and fails the build on any broken hash or signature. Proofs, when they exist, are verified
with a public triple — **SHA-256** (integrity), **Ed25519** (authorship), **OpenTimestamps**
(precedence) — never HMAC, which requires a shared key and cannot be verified by a third
party.

**Scaffolding fading.** Continuous learning is a condition of operation, not a suggestion:
a node that stops generating situated (teleological) signal decays toward isolation. The
support withdraws as competence rises.

The claim the repository makes about itself is deliberately narrow: **this is philosophy
that compiles, not an essay.** The theses are not original in isolation — their genealogy
is documented in [`PRIOR_ART.md`](PRIOR_ART.md), each debt and each divergence stated. What
is offered here is their assembly into an executable, refutable protocol.

## Status

**v1.0 · versioned · refutable.** Not immutable, not canonical — a living document under
version control. The concrete evidence that would force a revision of each Part is stated
in [Condiciones de Refutación](CODICE.md#condiciones-de-refutaci%C3%B3n).

## Contents

- [`CODICE.md`](CODICE.md) — the manifesto (Parts I–III, Epilogue, refutation conditions).
- [`PRIOR_ART.md`](PRIOR_ART.md) — genealogy: each thesis, its debt, and its divergence.
- [`proofs/`](proofs/) — verifiable proofs, or their honest absence (NO DATA at v1.0).
- [`CHANGELOG.md`](CHANGELOG.md) — what changed from the draft, and why.

## Verification

```bash
./proofs/verify_pow.sh
```

With no published proofs, it prints `NO DATA — 0 pruebas publicadas` and exits `0`. Any
hash or signature failure exits non-zero and breaks CI. See
[`proofs/README.md`](proofs/README.md) for the manifest schema and signing convention.

## License

Two licenses, deliberately separated so the verifier is reusable independently of the text:

- **Text** (`CODICE.md`, `PRIOR_ART.md`, `CHANGELOG.md`, this README): **CC BY-SA 4.0** —
  see [`LICENSE`](LICENSE).
- **Code** (`proofs/verify_pow.sh`, `.github/workflows/`): **MIT** — see
  [`LICENSE-CODE`](LICENSE-CODE).
