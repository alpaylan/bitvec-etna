module Main where

import Etna.Result    (PropertyResult(..))
import Etna.Witnesses
  ( witness_read_bit_round_trip_case_true
  , witness_read_bit_round_trip_case_false
  , witness_f2_poly_signum_one_case_three
  , witness_f2_poly_signum_one_case_fortytwo
  , witness_bit_index_word_offset_case_pos100_len200
  , witness_bit_index_word_offset_case_pos130_len150
  )
import System.Exit    (exitFailure, exitSuccess)

cases :: [(String, PropertyResult)]
cases =
  [ ("witness_read_bit_round_trip_case_true",            witness_read_bit_round_trip_case_true)
  , ("witness_read_bit_round_trip_case_false",           witness_read_bit_round_trip_case_false)
  , ("witness_f2_poly_signum_one_case_three",             witness_f2_poly_signum_one_case_three)
  , ("witness_f2_poly_signum_one_case_fortytwo",          witness_f2_poly_signum_one_case_fortytwo)
  , ("witness_bit_index_word_offset_case_pos100_len200", witness_bit_index_word_offset_case_pos100_len200)
  , ("witness_bit_index_word_offset_case_pos130_len150", witness_bit_index_word_offset_case_pos130_len150)
  ]

main :: IO ()
main = do
  let failures =
        [ (n, msg) | (n, Fail msg) <- cases ] ++
        [ (n, "discard") | (n, Discard) <- cases ]
  if null failures
    then do
      putStrLn $ "OK: all " ++ show (length cases) ++ " witnesses passed"
      exitSuccess
    else do
      mapM_ (\(n, m) -> putStrLn (n ++ ": FAIL: " ++ m)) failures
      exitFailure
