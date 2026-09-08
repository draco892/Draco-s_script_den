#!/usr/bin/env bash

# --- SAFETY SETTINGS ---
# -e: Exit immediately if a command fails
# -u: Treat unset variables as an error
# -o pipefail: Return the exit code of the first command in a pipe that fails
set -euo pipefail

# Prevent filename errors if no .jpeg files exist
shopt -s nullglob

# Force number formatting to use dots instead of commas (crucial for math consistency)
export LC_NUMERIC=C

# Create output directory
mkdir -p WITH_LOGO

# --- FILE DISCOVERY ---
files=( *.jpeg )
total=${#files[@]}

if [ "$total" -eq 0 ]; then
echo "No .jpeg files found."
exit 0
fi

# --- PARALLELISM SETUP ---
# Find number of CPU cores using sysctl, but cap the work at the 75% of the maxium core capacity
jobs=$(sysctl -n hw.ncpu)
jobs=$(( jobs * 75 / 100 ))
jobs=$(( jobs < 1 ? 1 : jobs ))

# Create a temporary file to track progress across different parallel processes
progress_file=$(mktemp)
echo 0 > "$progress_file"

# --- THE WORKER FUNCTION ---
# This function runs inside every background process
process_one() {
   local idx="$1" # The unique index number
   local file="$2" # The filename

   # Extract width and height using string manipulation (very fast)
   dimensions=$(magick identify -format "%w %h" "$file")
   width=${dimensions% *} # Everything before the space
   height=${dimensions#* } # Everything after the space

   # Calculate logo size:
   # 1. Extreme panoramas (aspect ratio > 3:1): use height-based scaling.
   # 2. Vertical images (aspect ratio < 1): use a larger diagonal proportion.
   # 3. Regular horizontal/square (1 <= aspect ratio <= 3): use a reduced diagonal proportion.
   aspect_ratio=$(echo "$width / $height" | bc -l)
   if (( $(echo "$aspect_ratio > 3" | bc -l) )); then
      # Panoramic scaling: height/6 is a good balance for extreme widths
      logo_size=$(printf "%.0f" "$(echo "$height / 6" | bc -l)")
   elif (( $(echo "$aspect_ratio < 1" | bc -l) )); then
      # Vertical scaling: balanced size (approx 80% of diagonal / 10)
      calc_val=$(echo "sqrt($width*$width + $height*$height)*0.80" | bc -l)
      logo_size=$(printf "%.0f" "$(echo "$calc_val / 10" | bc -l)")
   else
      # Regular horizontal/square scaling: reduced by 30% (diagonal * 0.70 / 12)
      calc_val=$(echo "sqrt($width*$width + $height*$height)*0.70" | bc -l)
      logo_size=$(printf "%.0f" "$(echo "$calc_val / 12" | bc -l)")
   fi

   # Apply the logo via ImageMagick with 50% opacity (1.0 no transparency, 0.30 70% transparency and so on)
   magick -limit thread 1 "$file" \
   \( "../../../Draco_logo/logo_White.png" \
      -resize "${logo_size}x" \
      -channel A -evaluate multiply 0.50 +channel \
   \) \
   -gravity SouthEast \
   -geometry +10+10 \
   -composite \
   "WITH_LOGO/DRA_SIG26_$(printf "%03d" "$idx").jpeg"

   # --- PROGRESS TRACKING (Atomic Update) ---
   # Read the current count, increment it, and write it back to the temp file
   done_count=$(( $(cat "$progress_file") + 1 ))
   echo "$done_count" > "$progress_file"

   # Visual Progress Bar Output
   # This creates a bar using '#' characters based on percentage done
   printf "\r[%s] %3d%% processed: %d left: %d" \
   "$(printf '%*s' "$(( done_count * 40 / total ))" '' | tr ' ' '#')" \
   "$(( done_count * 100 / total ))" \
   "$done_count" \
   "$(( total - done_count ))"
}

# Export the function and variables so xargs can see them in sub-shells
export -f process_one
export total progress_file

# --- EXECUTION ENGINE (The Pipeline) ---
i=1
for file in "${files[@]}"; do
# We use a 'null separator' (\0) to handle filenames that have spaces safely
printf '%s\0%s\0' "$i" "$file"
i=$((i + 1))
done | xargs -0 -n 2 -P "$jobs" bash -c 'process_one "$@"' _

# --- CLEANUP ---
printf "\n\n\nDone. Processed %d files using %d parallel jobs.\n\n" "$total" "$jobs"
rm -f "$progress_file" # Remove the temporary counter file