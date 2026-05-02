module Etna.Properties where

import qualified Data.Vector.Unboxed as U
import           Data.Bit            (Bit(..), F2Poly, bitIndex)

import Etna.Result

------------------------------------------------------------------------------
-- Variant 1: read_instance_returns_false_779e7d55_1
-- "Fix Read instance of Bit"
--
-- The buggy 'Read Bit' parsed @"1"@ as @Bit False@; only @"0"@ round-tripped
-- through @show@/@read@. The property forces both bits to round-trip.
------------------------------------------------------------------------------

newtype ReadBitArgs = ReadBitArgs { rbBool :: Bool }
  deriving (Show, Eq)

property_read_bit_round_trip :: ReadBitArgs -> PropertyResult
property_read_bit_round_trip (ReadBitArgs b) =
  let rendered = show (Bit b)
      parsed   = read rendered :: Bit
      expected = Bit b
  in if parsed == expected
        then Pass
        else Fail $
          "read . show $ Bit " ++ show b ++ " = " ++ show parsed
            ++ "; expected " ++ show expected
            ++ "; rendering = " ++ show rendered

------------------------------------------------------------------------------
-- Variant 2: f2poly_signum_id_aba8a62f_1
-- "Fix F2Poly.signum"
--
-- The buggy F2Poly.signum was @id@: it returned the input polynomial
-- unchanged. The fix: signum of any non-zero polynomial is the constant 1.
-- (The zero polynomial is left out of the property: 'signum 0' would itself
-- be 0 and Discard avoids confusing the buggy 'id' with the right answer.)
------------------------------------------------------------------------------

newtype F2PolySignumArgs = F2PolySignumArgs { f2sigInt :: Integer }
  deriving (Show, Eq)

property_f2_poly_signum_one :: F2PolySignumArgs -> PropertyResult
property_f2_poly_signum_one (F2PolySignumArgs n)
  | n <= 0    = Discard
  | otherwise =
      let p :: F2Poly
          p = fromInteger n
          s = signum p
          one_ = 1 :: F2Poly
      in if s == one_
            then Pass
            else Fail $
              "signum (" ++ show p ++ " :: F2Poly) = " ++ show s
                ++ "; expected " ++ show one_
                ++ " (input integer was " ++ show n ++ ")"

------------------------------------------------------------------------------
-- Variant 3: bit_index_misses_word_offset_4ce4b318_1
-- "Fix a grave bug in bitIndex"
--
-- The buggy 'bitIndexInWords' returned the bit's position within the word
-- it was found in, ignoring how many words had already been searched. So
-- @bitIndex (Bit True) v@ would return e.g. @Just 36@ for a vector whose
-- only set bit was at index 100 (= 64 + 36). The fix adds the word offset
-- back in.
--
-- The property compares 'bitIndex 1 v' against a naive linear scan and
-- forces inputs that take the non-SIMD code path: vectors whose length is
-- not word-aligned (so SIMD's fast path does not apply) and whose set bit
-- lives outside the first word.
------------------------------------------------------------------------------

data BitIndexArgs = BitIndexArgs
  { biLen :: !Int
  , biPos :: !Int
  } deriving (Show, Eq)

property_bit_index_word_offset :: BitIndexArgs -> PropertyResult
property_bit_index_word_offset (BitIndexArgs len pos)
  | len <= 0          = Discard
  | pos < 0           = Discard
  | pos >= len        = Discard
  | (len `mod` 64) == 0 = Discard
  -- pos in the first word would already work under the buggy 'bitIndexInWords',
  -- so for symmetry across base-vs-buggy we force the bit into word >= 1.
  | pos < 64          = Discard
  | otherwise =
      let v :: U.Vector Bit
          v = U.generate len (\i -> Bit (i == pos))
          actual = bitIndex (Bit True) v
          expected = Just pos
      in if actual == expected
            then Pass
            else Fail $
              "bitIndex 1 (length=" ++ show len ++ ", set=" ++ show pos
                ++ ") = " ++ show actual
                ++ "; expected " ++ show expected
