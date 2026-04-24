#!/usr/bin/env bash
# optimize-images.sh
# macOS script that compresses and resizes images in components/assets
# Produces optimized output in components/assets/optimized

set -euo pipefail

SRC_DIR="$(pwd)/components/assets"
OUT_DIR="$SRC_DIR/optimized"
QUALITY=80  # JPEG quality (0-100)
MAX_WIDTH=1920

mkdir -p "$OUT_DIR"

echo "Optimizing images from: $SRC_DIR"

shopt -s nullglob
count=0
for img in "$SRC_DIR"/*.{jpg,jpeg,png,JPG,JPEG,PNG}; do
  [ -f "$img" ] || continue
  filename=$(basename "$img")
  ext=${filename##*.}
  name=${filename%.*}

  # macOS's default bash may be older and not support ${var,,}; use tr to lowercase the extension
  ext_lc=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  out="$OUT_DIR/${name}.${ext_lc}"

  if [[ "$ext_lc" == "png" ]]; then
    # Convert PNG to optimized PNG using sips (lossless) then optionally convert to JPEG for smaller size
    sips -s format png "$img" --out "$out" >/dev/null
    # Optionally convert to JPEG for web if transparency not required
    # sips -s format jpeg -s formatOptions $QUALITY "$img" --out "$OUT_DIR/${name}.jpg" >/dev/null
  else
    # For jpeg/jpg, resize if wider than MAX_WIDTH and set quality
    width=$(sips -g pixelWidth "$img" | awk '/pixelWidth/ {print $2}')
    if [ "$width" -gt "$MAX_WIDTH" ]; then
      sips -Z $MAX_WIDTH "$img" --out "$out" >/dev/null
    else
      cp "$img" "$out"
    fi
    # Set JPEG quality
    sips -s format jpeg -s formatOptions $QUALITY "$out" --out "$out" >/dev/null || true
  fi

  echo "-> Optimized: $filename -> $(basename "$out")"
  count=$((count+1))
done

echo "Optimization complete. Processed $count files. Output folder: $OUT_DIR"