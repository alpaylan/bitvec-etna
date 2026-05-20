module Etna.Gens.Hedgehog where

import           Hedgehog       (Gen)
import qualified Hedgehog.Gen   as Gen
import qualified Hedgehog.Range as Range

import Etna.Properties
  ( ReadBitArgs(..)
  , F2PolySignumArgs(..)
  , BitIndexArgs(..)
  )

-- | Read-Bit round trip: any 'Bool'. Mirrors upstream
-- @Arbitrary Bit@ which is @Bit \<$\> arbitrary@.
gen_read_bit_round_trip :: Gen ReadBitArgs
gen_read_bit_round_trip = ReadBitArgs <$> Gen.bool

-- | F2Poly signum: any positive 'Integer'. We let Hedgehog scale the
-- range linearly with the test size and span up to ~10^9 so the
-- distribution covers small and large polynomials. The property
-- discards @n <= 0@.
gen_f2_poly_signum_one :: Gen F2PolySignumArgs
gen_f2_poly_signum_one =
  F2PolySignumArgs . toInteger <$>
    Gen.integral (Range.linear (1 :: Int) 1000000000)

-- | bitIndex word-offset: lengths up to ~4096 bits (64 words),
-- positions anywhere from word 1 onward. Hedgehog's linear range
-- scales naturally with the size parameter so shrinking still
-- finds small failing cases.
gen_bit_index_word_offset :: Gen BitIndexArgs
gen_bit_index_word_offset = do
  len <- Gen.int (Range.linear 65 4096)
  pos <- Gen.int (Range.linear 64 (len - 1))
  pure (BitIndexArgs len pos)
