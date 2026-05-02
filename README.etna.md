# bitvec — ETNA workload

This is the [bitvec](https://github.com/Bodigrim/bitvec) library forked
into an ETNA workload. The upstream files are untouched; the
workload-specific additions live in:

- `etna.toml` — manifest (single source of truth).
- `patches/*.patch` — bug-injection patches. Reverse-applying any patch
  re-introduces the original bug into the otherwise-fixed base tree.
- `etna/` — runner package (cabal). Defines `property_<snake>` functions,
  per-framework generators, witnesses, and the `etna-runner` CLI.
- `BUGS.md` / `TASKS.md` — generated. Regenerate with `etna workload doc .`.

## Library shape

bitvec is a single-package library that exposes `Data.Bit` (fast,
non-thread-safe) and `Data.Bit.ThreadSafe`. Heavy hitters such as
`zipBits`, `invertBits`, `reverseBits`, `bitIndex`, and `selectBits`
short-circuit to a C SIMD path (the `simd` cabal flag is on by default;
see `cbits/bitvec_simd.c`); pure-Haskell fallbacks live in
`src/Data/Bit/{Internal,Immutable,Mutable,F2Poly}.hs`.

This workload mines bug fixes that landed in the **pure-Haskell**
sources. CI / haddock / GHC-compat fixes and SIMD/FFI-only fixes are
filtered out at discover time. Three correctness fixes against modern
HEAD are reproduced as patches:

- `bit_index_misses_word_offset_4ce4b318_1` (Immutable.hs)
- `f2poly_signum_id_aba8a62f_1` (F2Poly.hs)
- `read_instance_returns_false_779e7d55_1` (Internal.hs)

The `bitIndex` variant deliberately picks inputs (non-word-aligned
length, set bit in word ≥ 1) that bypass the SIMD short-circuit, so
the bug surfaces in the Haskell fallback even with the `simd` flag on.

## Frameworks

Four PBT backends drive the same property:

- **QuickCheck** — random, shrinking; tier-1 reference.
- **Hedgehog** — integrated shrinking; alternative random search.
- **Falsify** — newer integrated-shrinking backend with sample-tree shrinking.
- **SmallCheck** — bounded enumeration; symbolic-style baseline.

Plus a witness-replay tool `etna` for fidelity checks.

## Quickstart

```sh
# 1. Pin a modern GHC (falsify needs base >= 4.18 = GHC >= 9.6).
ghcup install ghc 9.6.6
# cabal.project already pins with-compiler to ghc 9.6.6.

# 2. Build the runner.
cabal build etna-runner

# 3. Witness fidelity check.
cabal test etna-witnesses

# 4. Run a property under each backend (base = fixed; expect "passed").
for tool in quickcheck hedgehog falsify smallcheck; do
  cabal run -v0 etna-runner -- "$tool" ReadBitRoundTrip
done

# 5. Reverse-apply a patch (install the bug), re-run, expect "failed".
git apply -R --whitespace=nowarn patches/read_instance_returns_false_779e7d55_1.patch
cabal run -v0 etna-runner -- quickcheck ReadBitRoundTrip
git apply    --whitespace=nowarn patches/read_instance_returns_false_779e7d55_1.patch
```

## Validating

```sh
python3 ../../../scripts/check_haskell_workload.py .
```

Runs the same invariant checks the pre-commit hook would (manifest parses,
patches reverse-apply, properties / generators / witnesses exist, runner's
`allProperties` matches the manifest, BUGS.md / TASKS.md exist).
