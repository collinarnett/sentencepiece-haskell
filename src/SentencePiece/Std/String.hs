{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

-- |
--  This software includes modifications based on code from the "Hercules CI Agent" project
--  (https://github.com/hercules-ci/hercules-ci-agent), licensed under the Apache License 2.0.
--  Original Apache License 2.0 applies to these modifications.
--  For the original license, see http://www.apache.org/licenses/LICENSE-2.0.
--  We thank Hercules CI for their contributions to the open source community.
module SentencePiece.Std.String
  ( CStdString,
    stdStringCtx,
    moveToByteString,
    withString,
    new,
    delete,
    copyToByteString,
  )
where

import Control.Exception (bracket, mask_)
import Data.ByteString (ByteString)
import Data.ByteString.Unsafe (unsafePackMallocCStringLen)
import Foreign hiding (new)
import qualified Language.C.Inline as C
import SentencePiece.Encapsulation
import SentencePiece.Std.String.Context
import SentencePiece.Std.String.Instances ()
import System.IO.Unsafe (unsafePerformIO)
import Prelude

C.context (stdStringCtx <> C.bsCtx <> C.fptrCtx)

C.include "<string>"
C.include "<cstring>"

moveToByteString :: Ptr CStdString -> IO ByteString
moveToByteString s = mask_ $ alloca \ptr -> alloca \sz -> do
  [C.block| void {
    const std::string &s = *$(std::string *s);
    size_t sz = *$(size_t *sz) = s.size();
    char *ptr = *$(char **ptr) = (char*)malloc(sz);
    std::memcpy((void *)ptr, s.c_str(), sz);
  }|]
  sz' <- peek sz
  ptr' <- peek ptr
  unsafePackMallocCStringLen (ptr', fromIntegral sz')

new :: ByteString -> IO (Ptr CStdString)
new bs =
  [C.block|std::string* {
    return new std::string($bs-ptr:bs, $bs-len:bs);
  }|]

delete :: Ptr CStdString -> IO ()
delete bs = [C.block| void { delete $(std::string *bs); }|]

withString :: ByteString -> (Ptr CStdString -> IO a) -> IO a
withString bs = bracket (new bs) delete

finalize :: FinalizerPtr CStdString
{-# NOINLINE finalize #-}
finalize =
  unsafePerformIO
    [C.exp|
      void (*)(std::string *) {
        [](std::string *v) {
          delete v;
        }
      }
    |]

newtype StdString = StdString (ForeignPtr CStdString)

instance HasEncapsulation CStdString StdString where
  moveToForeignPtrWrapper x = StdString <$> newForeignPtr finalize x

copyToByteString :: StdString -> IO ByteString
copyToByteString (StdString s) = mask_ $ alloca \ptr -> alloca \sz -> do
  [C.block| void {
    const std::string &s = *$fptr-ptr:(std::string *s);
    size_t sz = *$(size_t *sz) = s.size();
    char *ptr = *$(char **ptr) = (char*)malloc(sz);
    std::memcpy((void *)ptr, s.c_str(), sz);
  }|]
  sz' <- peek sz
  ptr' <- peek ptr
  unsafePackMallocCStringLen (ptr', fromIntegral sz')
