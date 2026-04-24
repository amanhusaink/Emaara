Image optimization

This folder contains site assets. To compress and resize images on macOS, run the helper script located at `scripts/optimize-images.sh`.

Usage:

```bash
# from the repository root
chmod +x scripts/optimize-images.sh
./scripts/optimize-images.sh
```

The script writes optimized images to `components/assets/optimized` (JPEG quality 80, max width 1920). PNG files are passed through sips as PNG; uncomment the conversion line in the script if you want PNGs converted to JPEG.
