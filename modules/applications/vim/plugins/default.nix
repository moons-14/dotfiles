{ lib, ... }@args:
lib.mkMerge [
  (import ./editor args)
  (import ./ui args)
]
