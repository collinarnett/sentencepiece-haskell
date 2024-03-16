{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

module SentencePiece.SentencePieceProcessor where

import Foreign
import qualified Language.C.Inline as C
import qualified Language.C.Inline.Cpp.Exception as C
import SentencePiece.Context
import SentencePiece.Encapsulation

C.context context

C.include "sentencepiece_processor.h"

newtype SentencePieceProcessor = SentencePieceProcessor (ForeignPtr CSentencePieceProcessor)

instance HasEncapsulation CSentencePieceProcessor SentencePieceProcessor where
  moveToForeignPtrWrapper x = SentencePieceProcessor <$> newForeignPtr deleteSentencePieceProcessor x

newSentencePieceProcessor :: IO (Ptr CSentencePieceProcessor)
newSentencePieceProcessor =
  [C.throwBlock|sentencepiece::SentencePieceProcessor* {
  auto processor = new sentencepiece::SentencePieceProcessor();
  return processor;
}|]

deleteSentencePieceProcessor :: FunPtr (Ptr CSentencePieceProcessor -> IO ())
deleteSentencePieceProcessor =
  [C.funPtr|
  void delete_sentencepiece_processor(sentencepiece::SentencePieceProcessor* processor) { delete processor; }
|]
