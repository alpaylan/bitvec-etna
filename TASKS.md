# bitvec — ETNA Tasks

Total tasks: 12

## Task Index

| Task | Variant | Framework | Property | Witness |
|------|---------|-----------|----------|---------|
| 001 | `bit_index_misses_word_offset_4ce4b318_1` | quickcheck | `BitIndexWordOffset` | `witness_bit_index_word_offset_case_pos100_len200` |
| 002 | `bit_index_misses_word_offset_4ce4b318_1` | hedgehog   | `BitIndexWordOffset` | `witness_bit_index_word_offset_case_pos100_len200` |
| 003 | `bit_index_misses_word_offset_4ce4b318_1` | falsify    | `BitIndexWordOffset` | `witness_bit_index_word_offset_case_pos100_len200` |
| 004 | `bit_index_misses_word_offset_4ce4b318_1` | smallcheck | `BitIndexWordOffset` | `witness_bit_index_word_offset_case_pos100_len200` |
| 005 | `f2poly_signum_id_aba8a62f_1`             | quickcheck | `F2PolySignumOne`    | `witness_f2_poly_signum_one_case_three` |
| 006 | `f2poly_signum_id_aba8a62f_1`             | hedgehog   | `F2PolySignumOne`    | `witness_f2_poly_signum_one_case_three` |
| 007 | `f2poly_signum_id_aba8a62f_1`             | falsify    | `F2PolySignumOne`    | `witness_f2_poly_signum_one_case_three` |
| 008 | `f2poly_signum_id_aba8a62f_1`             | smallcheck | `F2PolySignumOne`    | `witness_f2_poly_signum_one_case_three` |
| 009 | `read_instance_returns_false_779e7d55_1`  | quickcheck | `ReadBitRoundTrip`   | `witness_read_bit_round_trip_case_true` |
| 010 | `read_instance_returns_false_779e7d55_1`  | hedgehog   | `ReadBitRoundTrip`   | `witness_read_bit_round_trip_case_true` |
| 011 | `read_instance_returns_false_779e7d55_1`  | falsify    | `ReadBitRoundTrip`   | `witness_read_bit_round_trip_case_true` |
| 012 | `read_instance_returns_false_779e7d55_1`  | smallcheck | `ReadBitRoundTrip`   | `witness_read_bit_round_trip_case_true` |

## Witness Catalog

- `witness_bit_index_word_offset_case_pos100_len200` — bitIndex 1 (length 200, set at 100) must equal Just 100
- `witness_bit_index_word_offset_case_pos130_len150` — bitIndex 1 (length 150, set at 130) must equal Just 130
- `witness_f2_poly_signum_one_case_three`             — signum (fromInteger 3 :: F2Poly) must equal 1
- `witness_f2_poly_signum_one_case_fortytwo`          — signum (fromInteger 42 :: F2Poly) must equal 1
- `witness_read_bit_round_trip_case_true`            — read (show (Bit True))  must equal Bit True
- `witness_read_bit_round_trip_case_false`           — read (show (Bit False)) must equal Bit False (always passes; pinned for symmetry)
