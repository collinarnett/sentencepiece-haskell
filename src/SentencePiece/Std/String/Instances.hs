{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-orphans #-}

-- | Define instances for C++ types in the Context module that can't be in that
-- module because of TH staging restrictions.
module SentencePiece.Std.String.Instances () where

import Data.Semigroup (Semigroup ((<>)))
import qualified Language.C.Inline.Cpp as C
import SentencePiece.Std.String.Context
import SentencePiece.Std.Vector

C.context (stdVectorCtx <> stdStringCtx)
C.include "<string>"

instanceStdVector "std::string"
