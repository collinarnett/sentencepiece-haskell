{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskellQuotes #-}

-- |
--  This software includes modifications based on code from the "Hercules CI Agent" project
--  (https://github.com/hercules-ci/hercules-ci-agent), licensed under the Apache License 2.0.
--  Original Apache License 2.0 applies to these modifications.
--  For the original license, see http://www.apache.org/licenses/LICENSE-2.0.
module SentencePiece.Context where

import qualified Data.Map as M
import qualified Language.C.Inline as C
import qualified Language.C.Inline.Context as C
import qualified Language.C.Inline.Cpp as C
import qualified Language.C.Types as C
import Prelude

data CSentencePieceProcessor

context :: C.Context
context =
  C.cppCtx
    <> mempty
      { C.ctxTypesTable =
          M.singleton (C.TypeName "sentencepiece::SentencePieceProcessor") [t|CSentencePieceProcessor|]
      }
