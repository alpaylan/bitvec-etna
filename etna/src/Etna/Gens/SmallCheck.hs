{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Etna.Gens.SmallCheck where

import qualified Test.SmallCheck.Series as SC

import Etna.Properties
  ( ReadBitArgs(..)
  , F2PolySignumArgs(..)
  , BitIndexArgs(..)
  )

-- | Both 'Bool' values, enumerated in order @True, False@ so the bug
-- (which mishandles the @"1"@ rendering) hits at depth 0.
series_read_bit_round_trip :: Monad m => SC.Series m ReadBitArgs
series_read_bit_round_trip =
  ReadBitArgs <$> SC.generate (\_ -> [True, False])

-- | Enumerate positive 'Integer' values. Small depths stay within
-- 'Int' range and exercise the buggy 'id' signum on a wide spread of
-- polynomials. We use a quadratic ramp so deeper SmallCheck depths
-- hit much larger F2Poly values while still being deterministic.
series_f2_poly_signum_one :: Monad m => SC.Series m F2PolySignumArgs
series_f2_poly_signum_one = do
  n <- SC.generate $ \d ->
    let cap = fromIntegral (max 1 d) :: Integer
    in [1 .. cap] ++ [cap + 1, cap * 2 + 3, cap * cap + 5]
  pure (F2PolySignumArgs n)

-- | Enumerate (len, pos) pairs over a wide grid: lengths spanning
-- @[65 .. 65 + 16 * d]@ (skipping word-aligned values) and positions
-- spanning @[64 .. len - 1]@ at a stride that keeps the enumeration
-- compact. This matches the upstream test convention of vectors up
-- to a few hundred bits while remaining library-faithful.
series_bit_index_word_offset :: Monad m => SC.Series m BitIndexArgs
series_bit_index_word_offset = SC.generate $ \d ->
  let cap     = 65 + 16 * max 1 d
      lengths = takeUntil 12
                  [ n | n <- [65 .. cap], n `mod` 64 /= 0 ]
      stride  = max 1 (cap `div` 8)
      mkPositions len =
        takeUntil 6
          [ p | p <- [64, 64 + stride .. len - 1] ]
          ++ [ len - 1 ]
  in [ BitIndexArgs len pos
     | len <- lengths
     , pos <- mkPositions len
     , pos < len
     , pos >= 64
     ]
  where
    takeUntil :: Int -> [a] -> [a]
    takeUntil = take
