module Etna.Gens.QuickCheck where

import qualified Test.QuickCheck as QC

import Etna.Properties
  ( ReadBitArgs(..)
  , F2PolySignumArgs(..)
  , BitIndexArgs(..)
  )

-- | Read-Bit round trip: @Bit b@ for any @Bool@. Upstream's @Arbitrary
-- Bit@ is just @Bit \<$\> arbitrary@; we mirror that and let
-- QuickCheck choose @True@/@False@ uniformly so the buggy clause
-- (which mishandles @"1"@) is exercised about half the time.
gen_read_bit_round_trip :: QC.Gen ReadBitArgs
gen_read_bit_round_trip = ReadBitArgs <$> QC.arbitrary
-- | F2Poly signum: any positive 'Integer'. Upstream's @Arbitrary
-- F2Poly@ is @toF2Poly \<$\> arbitrary@ over a 'U.Vector' 'Bit', so
-- the natural distribution covers a very wide range. We use
-- QuickCheck's sized 'Integer' generator with @abs@ to span small
-- and large polynomials uniformly; the property discards @n <= 0@.
gen_f2_poly_signum_one :: QC.Gen F2PolySignumArgs
gen_f2_poly_signum_one = QC.sized $ \sz -> do
  n <- QC.frequency
        [ (3, QC.choose (1, 1 + fromIntegral sz))
        , (3, QC.choose (1, 1 + fromIntegral sz * fromIntegral sz))
        , (4, fmap (succ . abs) (QC.arbitrary :: QC.Gen Integer))
        ]
  pure (F2PolySignumArgs n)

-- | bitIndex word-offset: pick a length and a set-bit position so the
-- bug surfaces. Length spans up to ~64 words (4096 bits), matching
-- upstream test sizes for vector bit work; the property discards
-- word-aligned lengths and positions in the first word, so the
-- distribution covers a wide library-faithful range without losing
-- any bug-triggering case.
gen_bit_index_word_offset :: QC.Gen BitIndexArgs
gen_bit_index_word_offset = QC.sized $ \sz -> do
  let cap = max 65 (min 4096 (65 + sz * 16))
  len <- QC.choose (65, cap)
  pos <- QC.choose (64, len - 1)
  pure (BitIndexArgs len pos)
