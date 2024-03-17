{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-orphans #-}

-- |
--  This software includes modifications based on code from the "Hercules CI Agent" project
--  (https://github.com/hercules-ci/hercules-ci-agent), licensed under the Apache License 2.0.
--  Original Apache License 2.0 applies to these modifications.
--  For the original license, see http://www.apache.org/licenses/LICENSE-2.0.
--  We thank Hercules CI for their contributions to the open source community.
module SentencePiece.Std.String.Instances () where

import Data.Semigroup ()
import qualified Language.C.Inline.Cpp as C
import SentencePiece.Std.String.Context
import SentencePiece.Std.Vector

C.context (stdVectorCtx <> stdStringCtx)
C.include "<string>"

instanceStdVector "std::string"
