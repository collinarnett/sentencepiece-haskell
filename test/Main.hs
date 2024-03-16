{-# LANGUAGE NoImplicitPrelude #-}

module Main (main) where

import Data.String
import Protolude
import SentencePiece

main :: IO ()
main = do
  processor <- load "./test/test_model.model"
  tokens <- encodeStr processor $ fromString "Hello World"
  str <- decodeStr processor tokens
  putStrLn str
