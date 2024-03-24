# sentencepiece-haskell

A very simple library containing haskell bindings for Google's
[sentencepiece](https://github.com/google/sentencepiece) C++ library.

## Usage

``` haskell
import SentencePiece
import Protolude

main = do
 processor <- load "/path/to/some/model"
 encodedTokens <- encodeStr processor $ fromString "Hello World"
 decodedTokens <- decodeStr processor encodedTokens
```
## Setup

1. Install Nix
2. Enable Flakes for Nix

## Building

`nix build .`

## Developing

`nix develop .`
