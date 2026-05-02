module Etna.Witnesses where

import Etna.Properties
import Etna.Result

------------------------------------------------------------------------------
-- Variant 1: read_instance_returns_false_779e7d55_1
------------------------------------------------------------------------------

witness_read_bit_round_trip_case_true :: PropertyResult
witness_read_bit_round_trip_case_true =
  property_read_bit_round_trip (ReadBitArgs True)

witness_read_bit_round_trip_case_false :: PropertyResult
witness_read_bit_round_trip_case_false =
  property_read_bit_round_trip (ReadBitArgs False)

------------------------------------------------------------------------------
-- Variant 2: f2poly_signum_id_aba8a62f_1
------------------------------------------------------------------------------

witness_f2_poly_signum_one_case_three :: PropertyResult
witness_f2_poly_signum_one_case_three =
  property_f2_poly_signum_one (F2PolySignumArgs 3)

witness_f2_poly_signum_one_case_fortytwo :: PropertyResult
witness_f2_poly_signum_one_case_fortytwo =
  property_f2_poly_signum_one (F2PolySignumArgs 42)

------------------------------------------------------------------------------
-- Variant 3: bit_index_misses_word_offset_4ce4b318_1
------------------------------------------------------------------------------

witness_bit_index_word_offset_case_pos100_len200 :: PropertyResult
witness_bit_index_word_offset_case_pos100_len200 =
  property_bit_index_word_offset (BitIndexArgs 200 100)

witness_bit_index_word_offset_case_pos130_len150 :: PropertyResult
witness_bit_index_word_offset_case_pos130_len150 =
  property_bit_index_word_offset (BitIndexArgs 150 130)
