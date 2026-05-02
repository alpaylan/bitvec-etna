# bitvec — Injected Bugs

Space-efficient bit vectors (Bodigrim/bitvec). Bug fixes mined from upstream history; modern HEAD is the base, each patch reverse-applies a fix to install the original bug. Mining concentrates on pure-Haskell paths (Internal, Immutable, F2Poly) and avoids C/SIMD/FFI subtrees.

Total mutations: 3

## Bug Index

| # | Variant | Name | Location | Injection | Fix Commit |
|---|---------|------|----------|-----------|------------|
| 1 | `bit_index_misses_word_offset_4ce4b318_1` | `bit_index_returns_within_word` | `src/Data/Bit/Immutable.hs:647` | `patch` | `4ce4b31872daa86d01ccab26ad58fbaacd26d978` |
| 2 | `f2poly_signum_id_aba8a62f_1` | `f2poly_signum_returns_input` | `src/Data/Bit/F2Poly.hs:110` | `patch` | `aba8a62f9893f0ba18ec11fc2dc6d6983a2896b6` |
| 3 | `read_instance_returns_false_779e7d55_1` | `read_bit_one_returns_false` | `src/Data/Bit/Internal.hs:121` | `patch` | `779e7d5534b9ab5367e2924964af4b906454f969` |

## Property Mapping

| Variant | Property | Witness(es) |
|---------|----------|-------------|
| `bit_index_misses_word_offset_4ce4b318_1` | `BitIndexWordOffset` | `witness_bit_index_word_offset_case_pos100_len200`, `witness_bit_index_word_offset_case_pos130_len150` |
| `f2poly_signum_id_aba8a62f_1` | `F2PolySignumOne` | `witness_f2_poly_signum_one_case_three`, `witness_f2_poly_signum_one_case_fortytwo` |
| `read_instance_returns_false_779e7d55_1` | `ReadBitRoundTrip` | `witness_read_bit_round_trip_case_true`, `witness_read_bit_round_trip_case_false` |

## Framework Coverage

| Property | quickcheck | hedgehog | falsify | smallcheck |
|----------|---------:|-------:|------:|---------:|
| `BitIndexWordOffset`   | ✓ | ✓ | ✓ | ✓ |
| `F2PolySignumOne`      | ✓ | ✓ | ✓ | ✓ |
| `ReadBitRoundTrip`     | ✓ | ✓ | ✓ | ✓ |

## Bug Details

### 1. bit_index_returns_within_word

- **Variant**: `bit_index_misses_word_offset_4ce4b318_1`
- **Location**: `src/Data/Bit/Immutable.hs:647` (inside `bitIndexInWords`)
- **Property**: `BitIndexWordOffset`
- **Witness(es)**:
  - `witness_bit_index_word_offset_case_pos100_len200` — bitIndex 1 (length 200, set at 100) must equal Just 100
  - `witness_bit_index_word_offset_case_pos130_len150` — bitIndex 1 (length 150, set at 130) must equal Just 130
- **Source**: internal — Fix a grave bug in bitIndex
  > The buggy `bitIndexInWords` returned the bit's position within the word it was found in, ignoring how many words had already been searched. So `bitIndex` would report e.g. `Just 36` for a vector whose only set bit was at index 100 (= word 1, bit 36). The fix adds the word offset back in via `mulWordSize (n - off) + r`.
- **Fix commit**: `4ce4b31872daa86d01ccab26ad58fbaacd26d978` — Fix a grave bug in bitIndex
- **Invariant violated**: For every non-empty vector v with a single set bit at position p (where p >= 64 and length v is not word-aligned, so the SIMD short-circuit does not apply), 'bitIndex (Bit True) v' must equal 'Just p'.
- **How the mutation triggers**: Reverse-applying the patch removes the word-offset addition in both branches of `bitIndexInWords`. For a length-200 vector with the only True bit at index 100, `bitIndex 1 v` then returns `Just 36` (= 100 mod 64) instead of `Just 100`.

### 2. f2poly_signum_returns_input

- **Variant**: `f2poly_signum_id_aba8a62f_1`
- **Location**: `src/Data/Bit/F2Poly.hs:110` (inside `instance Num F2Poly / signum`)
- **Property**: `F2PolySignumOne`
- **Witness(es)**:
  - `witness_f2_poly_signum_one_case_three` — signum (fromInteger 3 :: F2Poly) must equal 1
  - `witness_f2_poly_signum_one_case_fortytwo` — signum (fromInteger 42 :: F2Poly) must equal 1
- **Source**: internal — Fix F2Poly.signum
  > The original buggy F2Poly.signum was `id`: it returned the input polynomial unchanged. The fix returns the constant-1 polynomial for any non-zero input. (Modern HEAD's `const one` replaces the original `const (F2Poly (U.singleton (Bit True)))` — see commit a5216fc1 for the follow-up that taught `one` to construct a properly-aligned word array.) Reverse-applying installs the original `id` form.
- **Fix commit**: `aba8a62f9893f0ba18ec11fc2dc6d6983a2896b6` — Fix F2Poly.signum
- **Invariant violated**: For every non-zero F2Poly p, `signum p` must equal `1 :: F2Poly`. (For the zero polynomial, signum is 0; the property discards zero inputs to keep base-vs-buggy detection orthogonal.)
- **How the mutation triggers**: Reverse-applying the patch swaps `signum = const one` for `signum = id`. Calling `signum (3 :: F2Poly)` then returns the input polynomial `0b11` instead of `1`.

### 3. read_bit_one_returns_false

- **Variant**: `read_instance_returns_false_779e7d55_1`
- **Location**: `src/Data/Bit/Internal.hs:121` (inside `Read Bit / readsPrec`)
- **Property**: `ReadBitRoundTrip`
- **Witness(es)**:
  - `witness_read_bit_round_trip_case_true` — read (show (Bit True)) must equal Bit True
  - `witness_read_bit_round_trip_case_false` — read (show (Bit False)) must equal Bit False (always passes; pinned for symmetry)
- **Source**: internal — Fix Read instance of Bit
  > The buggy `Read Bit` instance parsed the input character `'1'` as `Bit False` (only `'0'` round-tripped through `show`/`read`). The fix returns `Bit True` for `'1'`, making `read . show` total.
- **Fix commit**: `779e7d5534b9ab5367e2924964af4b906454f969` — Fix Read instance of Bit
- **Invariant violated**: For every Bool b, `read (show (Bit b)) :: Bit` must equal `Bit b`. Equivalently, the Read instance for Bit must round-trip with the Show instance, in particular for `'1'`.
- **How the mutation triggers**: Reverse-applying the patch reverts the second clause of `readsPrec` so that the input character `'1'` is parsed as `Bit False`. Calling `read "1" :: Bit` then returns `Bit False` rather than `Bit True`.
