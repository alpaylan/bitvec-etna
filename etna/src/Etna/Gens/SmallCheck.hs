{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Etna.Gens.SmallCheck where

import qualified Test.SmallCheck.Series as SC

import Etna.Properties
  ( ReadBitArgs(..)
  , F2PolySignumArgs(..)
  , BitIndexArgs(..)
  )

series_read_bit_round_trip :: Monad m => SC.Series m ReadBitArgs
series_read_bit_round_trip = ReadBitArgs <$> SC.generate (\_ -> [True, False])

-- Enumerate small positive integers up to ~depth.
series_f2_poly_signum_one :: Monad m => SC.Series m F2PolySignumArgs
series_f2_poly_signum_one = do
  n <- SC.generate (\d -> [1 .. fromIntegral (max 1 d) + 1])
  pure (F2PolySignumArgs n)

-- Enumerate (len, pos) pairs directly — len is non-word-aligned and pos
-- lives in word >= 1 so the buggy 'bitIndexInWords' returns the wrong
-- offset. We pick from a small explicit list to keep depth bounded.
series_bit_index_word_offset :: Monad m => SC.Series m BitIndexArgs
series_bit_index_word_offset = SC.generate $ \d ->
  let pairs =
        [ BitIndexArgs 100 64
        , BitIndexArgs 100 99
        , BitIndexArgs 127 64
        , BitIndexArgs 127 100
        , BitIndexArgs 127 126
        , BitIndexArgs 200 100
        , BitIndexArgs 200 130
        , BitIndexArgs 200 199
        ]
  in take (max 1 (d + 1)) pairs
