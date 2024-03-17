{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE NoImplicitPrelude #-}

module SentencePiece
  ( encodeStr,
    load,
    decodeStr,
  )
where

import Data.ByteString hiding (map)
import Foreign.C.String
import Foreign.ForeignPtr
import Foreign.Ptr
import qualified Language.C.Inline.Context as C
import qualified Language.C.Inline.Cpp as C
import qualified Language.C.Inline.Cpp.Unsafe as C
import Protolude
import SentencePiece.Context
import SentencePiece.Encapsulation (moveToForeignPtrWrapper)
import SentencePiece.SentencePieceProcessor
import SentencePiece.Std.String (stdStringCtx)
import qualified SentencePiece.Std.String as Std.String
import SentencePiece.Std.String.Instances ()
import SentencePiece.Std.Vector (stdVectorCtx)
import qualified SentencePiece.Std.Vector as Std.Vector
import System.Directory (makeAbsolute)

C.context (context <> stdVectorCtx <> stdStringCtx <> C.fptrCtx)

C.include "<cstring>"
C.include "<string>"
C.include "<vector>"
C.include "sentencepiece_processor.h"

byteStringList :: IO (Ptr (Std.Vector.CStdVector Std.String.CStdString)) -> IO [ByteString]
byteStringList x =
  x
    >>= moveToForeignPtrWrapper
    >>= Std.Vector.toListFP
    >>= traverse Std.String.copyToByteString

load :: FilePath -> IO SentencePieceProcessor
load fp = do
  model <- makeAbsolute fp
  processor <- newSentencePieceProcessor >>= newForeignPtr deleteSentencePieceProcessor
  withForeignPtr processor $
    \cprocessor -> withCString model $
      \cmodel ->
        [C.throwBlock|void {
    $(sentencepiece::SentencePieceProcessor* cprocessor)->LoadOrDie($(char* cmodel));
  }|]
  return $ SentencePieceProcessor processor

encodeStr :: SentencePieceProcessor -> ByteString -> IO [ByteString]
encodeStr (SentencePieceProcessor processor) text = byteStringList $
  Std.String.withString text $ \cstring ->
    withForeignPtr processor $ \cprocessor ->
      [C.throwBlock|std::vector<std::string>* {
      auto pieces = new std::vector<std::string>();
      $(sentencepiece::SentencePieceProcessor* cprocessor)->Encode(*$(std::string *cstring), pieces);
      return pieces;
    }|]

decodeStr :: SentencePieceProcessor -> [ByteString] -> IO ByteString
decodeStr (SentencePieceProcessor processor) pieces = do
  vec <- Std.Vector.new
  for_ pieces (\p -> Std.String.withString p (Std.Vector.pushBackP vec))
  result <- withForeignPtr processor $ \cprocessor ->
    [C.throwBlock| std::string* {
            auto text = new std::string();
            $(sentencepiece::SentencePieceProcessor* cprocessor)->Decode(*$fptr-ptr:(std::vector<std::string>* vec), text);
            return text;
        }|]
  Std.String.moveToByteString result
