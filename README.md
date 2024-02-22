# sentencepiece-haskell

A very simple library containing haskell bindings for Google's
[sentencepiece](https://github.com/google/sentencepiece) C++ library.

## Usage

``` haskell
-- Load a sentencepiece model
let processor = load "./path/to/some-tokenizer.model" :: Ptr SentencePieceProcessor
detokenize processor (tokenize processor "Hello World" :: Ptr(StdVector StdString)) :: IO String
```
## Setup

1. Install Nix
2. Enable Flakes for Nix

## Building

`nix build .`

## Developing

`nix develop .`
