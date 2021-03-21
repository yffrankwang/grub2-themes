#!/bin/bash

THEMES=("color" "white" "whitesur" "select")
SIZES=("32x" "48x" "64x")

for theme in "${THEMES[@]}"; do
  for size in "${SIZES[@]}"; do
    echo "./render-assets.sh \"$theme\" \"$size\": "
    bash ./render-assets.sh "$theme" "$size"
  done
done
