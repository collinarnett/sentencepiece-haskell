{-# LANGUAGE FunctionalDependencies #-}

-- |
--  This software includes modifications based on code from the "Hercules CI Agent" project
--  (https://github.com/hercules-ci/hercules-ci-agent), licensed under the Apache License 2.0.
--  Original Apache License 2.0 applies to these modifications.
--  For the original license, see http://www.apache.org/licenses/LICENSE-2.0.
module SentencePiece.Encapsulation
  ( HasEncapsulation (..),
    nullableMoveToForeignPtrWrapper,
  )
where

import Foreign (Ptr, nullPtr)
import Prelude

class HasEncapsulation a b | b -> a where
  -- | Takes ownership of the pointer, freeing/finalizing the pointer when
  -- collectable.
  moveToForeignPtrWrapper :: Ptr a -> IO b

nullableMoveToForeignPtrWrapper :: (HasEncapsulation a b) => Ptr a -> IO (Maybe b)
nullableMoveToForeignPtrWrapper rawPtr | rawPtr == nullPtr = pure Nothing
nullableMoveToForeignPtrWrapper rawPtr = Just <$> moveToForeignPtrWrapper rawPtr
