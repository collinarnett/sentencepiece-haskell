{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskellQuotes #-}

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
