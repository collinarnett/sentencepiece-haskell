{-# LANGUAGE NoImplicitPrelude #-}

module Main (main) where

import Data.String
import Protolude
import SentencePiece
import Test.Hspec

main :: IO ()
main = hspec $ do
  describe "SentencePiece.encodeStr" $ do
    it "encodes a bytestring to a list of tokens" $ do
      processor <- load "./test/test_model.model"
      encodeStr processor input `shouldReturn` (output :: [ByteString])
  describe "SentencePiece.decodeStr" $ do
    it "decodes a list of tokens to a bytestring" $ do
      processor <- load "./test/test_model.model"
      decodeStr processor output `shouldReturn` (input :: ByteString)
  where
    input = fromString "Hello World"
    output = map fromString ["â\150\129He", "ll", "o", "â\150\129", "W", "or", "l", "d"]
