module Etna.Gens.Falsify where

import qualified Test.Falsify.Generator as F
import qualified Test.Falsify.Range     as FR

import Etna.Properties
  ( ReadBitArgs(..)
  , F2PolySignumArgs(..)
  , BitIndexArgs(..)
  )

-- | Read-Bit round trip: any 'Bool'. Falsify's 'F.bool' biases toward
-- 'False' (the shrink target); we keep the natural distribution.
gen_read_bit_round_trip :: F.Gen ReadBitArgs
gen_read_bit_round_trip = ReadBitArgs <$> F.bool True

-- | F2Poly signum: positive 'Word' value, then promoted to
-- 'Integer'. The range is wide-but-bounded ('Word' caps at 2^64 - 1)
-- and origin-shrinks toward 1 so failing cases reduce.
gen_f2_poly_signum_one :: F.Gen F2PolySignumArgs
gen_f2_poly_signum_one = do
  n <- F.inRange (FR.withOrigin (1 :: Word, 1000000000) 1)
  pure (F2PolySignumArgs (fromIntegral n))

-- | bitIndex word-offset: length up to 4096 bits (64 words),
-- position from word 1 onward. Length is sampled first (with origin
-- 65) and position is sampled in @[64, len-1]@.
gen_bit_index_word_offset :: F.Gen BitIndexArgs
gen_bit_index_word_offset = do
  lenW <- F.inRange (FR.withOrigin (65 :: Word, 4096) 65)
  let len = fromIntegral lenW :: Int
  posW <- F.inRange (FR.withOrigin (64 :: Word, fromIntegral (len - 1)) 64)
  pure (BitIndexArgs len (fromIntegral posW))
