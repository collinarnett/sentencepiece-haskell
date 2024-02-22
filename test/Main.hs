module Main (main) where

import SentencePiece
  
main :: IO ()
main =  do
  processor <- load "./test/test_model.model"
  tokens <- tokenize processor "Hello World"
  str <- detokenize processor tokens
  putStrLn str 
