#!/bin/bash

# Get the script's name so we don't touch it
SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define categories and corresponding extensions
declare -A CATEGORIES=(
  [Pictures]="jpg jpeg png gif bmp svg webp"
  [Videos]="mp4 mkv mov avi webm flv"
  [Documents]="pdf doc docx txt odt xls xlsx ppt pptx epub"
  [Music]="mp3 flac wav ogg m4a"
  [Archives]="zip tar gz bz2 rar 7z"
  [Code]="c cpp py sh js ts html css java go rs"
)

# Tracking counters
declare -A FILE_COUNTS
TOTAL=0

echo "🧹 Starting file organization in: $SCRIPT_DIR"
echo "🚫 Script itself will be skipped: $SCRIPT_NAME"
echo ""

# Create destination folders
for CATEGORY in "${!CATEGORIES[@]}"; do
  mkdir -p "$SCRIPT_DIR/$CATEGORY"
done
mkdir -p "$SCRIPT_DIR/Others"  # For uncategorized files

# Iterate over files in the directory
for FILE in "$SCRIPT_DIR"/*; do
  BASENAME=$(basename "$FILE")
  
  # Skip directories and this script
  if [[ -d "$FILE" || "$BASENAME" == "$SCRIPT_NAME" ]]; then
    continue
  fi

  EXT="${BASENAME##*.}"
  FOUND=0

  # Search for a matching category
  for CATEGORY in "${!CATEGORIES[@]}"; do
    for TYPE in ${CATEGORIES[$CATEGORY]}; do
      if [[ "$EXT" =~ ^$TYPE$ ]]; then
        echo "📁 Moving '$BASENAME' to '$CATEGORY/'"
        mv "$FILE" "$SCRIPT_DIR/$CATEGORY/"
        FILE_COUNTS[$CATEGORY]=$((FILE_COUNTS[$CATEGORY]+1))
        TOTAL=$((TOTAL+1))
        FOUND=1
        break
      fi
    done
    [[ "$FOUND" -eq 1 ]] && break
  done

  # If no category matched
  if [[ "$FOUND" -eq 0 ]]; then
    echo "📦 Moving '$BASENAME' to 'Others/'"
    mv "$FILE" "$SCRIPT_DIR/Others/"
    FILE_COUNTS["Others"]=$((FILE_COUNTS["Others"]+1))
    TOTAL=$((TOTAL+1))
  fi
done

echo ""
echo "✅ Done organizing files."
echo "📊 Summary:"
for CATEGORY in "${!FILE_COUNTS[@]}"; do
  echo "  - ${CATEGORY}: ${FILE_COUNTS[$CATEGORY]} file(s)"
done
echo "📦 Total files organized: $TOTAL"
