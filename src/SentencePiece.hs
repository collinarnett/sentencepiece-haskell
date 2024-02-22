{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}

module SentencePiece where
import System.Directory (makeAbsolute) 
import           Foreign.C.String             
import           Foreign.Ptr                  (Ptr)
import qualified Language.C.Inline.Cpp        as C
import qualified Language.C.Inline.Cpp.Unsafe as C

data SentencePieceProcessor
data StdString
data StdVector a

C.context $ C.cppCtx <> C.cppTypePairs [
  ("sentencepiece::SentencePieceProcessor", [t|SentencePieceProcessor|]),
  ("std::string", [t|StdString|]),
  ("std::vector", [t|StdVector|])]

C.include "vector"
C.include "string"
C.include "sentencepiece_processor.h"

string_c_str
  :: Ptr StdString
  -> IO String
string_c_str str = [C.throwBlock| const char* { return (*$(std::string* str)).c_str();}|] >>= peekCString

load :: FilePath -> IO (Ptr SentencePieceProcessor)
load model = do
  fp <- makeAbsolute model
  withCString fp $ \cmodel -> [C.throwBlock|sentencepiece::SentencePieceProcessor* {
    auto processor = new sentencepiece::SentencePieceProcessor();
    processor->LoadOrDie($(char* cmodel));
    return processor;
}|]

tokenize :: Ptr SentencePieceProcessor -> String -> IO (Ptr (StdVector StdString))
tokenize processor text = withCString text $ \ctext -> [C.throwBlock|std::vector<std::string>* {
    std::vector<std::string>* pieces = new std::vector<std::string>();
    $(sentencepiece::SentencePieceProcessor* processor)->Encode($(char *ctext), pieces);
    return pieces;
}|]

detokenize :: Ptr SentencePieceProcessor -> Ptr (StdVector StdString) -> IO String
detokenize processor pieces = do
  result <- [C.throwBlock|std::string* {
   std::string* text = new std::string();
   $(sentencepiece::SentencePieceProcessor* processor)->Decode(*$(std::vector<std::string>* pieces), text);
   return text;
}|]
  string_c_str result
