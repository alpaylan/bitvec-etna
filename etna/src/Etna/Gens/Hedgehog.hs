module Etna.Gens.Hedgehog where

import           Hedgehog       (Gen)
import qualified Hedgehog.Gen   as Gen
import qualified Hedgehog.Range as Range

import Etna.Properties
  ( ReadBitArgs(..)
  , F2PolySignumArgs(..)
  , BitIndexArgs(..)
  )

gen_read_bit_round_trip :: Gen ReadBitArgs
gen_read_bit_round_trip = ReadBitArgs <$> Gen.element [True, False]

gen_f2_poly_signum_one :: Gen F2PolySignumArgs
gen_f2_poly_signum_one =
  F2PolySignumArgs . fromIntegral <$>
    Gen.integral (Range.linear (1 :: Int) 1000000)

gen_bit_index_word_offset :: Gen BitIndexArgs
gen_bit_index_word_offset = do
  len <- Gen.filter (\n -> n `mod` 64 /= 0)
                    (Gen.int (Range.linear 65 256))
  pos <- Gen.int (Range.linear 64 (len - 1))
  pure (BitIndexArgs len pos)
