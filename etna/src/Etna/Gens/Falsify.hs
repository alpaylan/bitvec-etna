module Etna.Gens.Falsify where

import           Data.List.NonEmpty (NonEmpty(..))
import qualified Test.Falsify.Generator as F
import qualified Test.Falsify.Range     as FR

import Etna.Properties
  ( ReadBitArgs(..)
  , F2PolySignumArgs(..)
  , BitIndexArgs(..)
  )

ne :: [a] -> NonEmpty a
ne []     = error "Etna.Gens.Falsify.ne: empty list"
ne (x:xs) = x :| xs

gen_read_bit_round_trip :: F.Gen ReadBitArgs
gen_read_bit_round_trip = ReadBitArgs <$> F.elem (ne [True, False])

gen_f2_poly_signum_one :: F.Gen F2PolySignumArgs
gen_f2_poly_signum_one = do
  n <- F.inRange (FR.between (1 :: Word, 1000000))
  pure (F2PolySignumArgs (fromIntegral n))

gen_bit_index_word_offset :: F.Gen BitIndexArgs
gen_bit_index_word_offset = do
  let lenChoices = ne [n | n <- [65 .. 256], n `mod` 64 /= 0]
  len <- F.elem lenChoices
  pos <- F.inRange (FR.between (64 :: Word, fromIntegral (len - 1)))
  pure (BitIndexArgs len (fromIntegral pos))
