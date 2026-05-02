module Etna.Gens.QuickCheck where

import qualified Test.QuickCheck as QC

import Etna.Properties
  ( ReadBitArgs(..)
  , F2PolySignumArgs(..)
  , BitIndexArgs(..)
  )

gen_read_bit_round_trip :: QC.Gen ReadBitArgs
gen_read_bit_round_trip = ReadBitArgs <$> QC.elements [True, False]

gen_f2_poly_signum_one :: QC.Gen F2PolySignumArgs
gen_f2_poly_signum_one =
  F2PolySignumArgs <$> QC.choose (1, 1000000)

-- BitIndexArgs: pick a non-word-aligned length in [65, 256] and a position
-- in [64, len - 1] so the bit lives in a non-first word.
gen_bit_index_word_offset :: QC.Gen BitIndexArgs
gen_bit_index_word_offset = do
  len <- QC.choose (65, 256) `QC.suchThat` (\n -> n `mod` 64 /= 0)
  pos <- QC.choose (64, len - 1)
  pure (BitIndexArgs len pos)
