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

# Both logos and the separator share this opacity (0 = invisible, 1 = opaque).
LOGO_OPACITY=0.75
LOGO_1="/Users/draco892/Pictures/Logo/GH_logo/26/GH26_Logo.png"
LOGO_2="/Users/draco892/Pictures/Logo/Draco_logo/logo_White.png"

for command in magick bc; do
   command -v "$command" >/dev/null || { echo "Missing command: $command" >&2; exit 1; }
done
for logo in "$LOGO_1" "$LOGO_2"; do
   [ -r "$logo" ] || { echo "Cannot read logo: $logo" >&2; exit 1; }
done

# Keep event output separate from the single-logo script.
mkdir -p WITH_EVENT_LOGO

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

# --- THE WORKER FUNCTION ---
# This function runs inside every background process
process_one() {
   local idx="$1" # The unique index number
   local file="$2" # The filename

   local dimensions width height aspect_ratio logo_size calc_val gap separator_width

   # Extract width and height using string manipulation (very fast)
   dimensions=$(magick identify -format "%w %h" "$file")
   width=${dimensions% *} # Everything before the space
   height=${dimensions#* } # Everything after the space

   # Calculate the size of the identical square panels used for both logos:
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

   # Equal panels and equal gaps place the separator at the group's center.
   logo_size=$(( logo_size < 1 ? 1 : logo_size ))
   gap=$(( logo_size / 8 ))
   gap=$(( gap < 1 ? 1 : gap ))
   separator_width=$(( logo_size / 80 ))
   separator_width=$(( separator_width < 1 ? 1 : separator_width ))

   # Trim transparent margins before resizing, so visible artwork has a similar
   # size despite different PNG canvases. Center each logo in an equal panel.
   # Assemble on a transparent canvas and halve the entire group, including
   # gaps and separator, then apply the same opacity to all parts.
   # Fit the group to small/narrow photos while retaining the 10px corner margin.
   local max_width max_height
   max_width=$(( width > 20 ? width - 20 : 1 ))
   max_height=$(( height > 20 ? height - 20 : 1 ))
   magick -limit thread 1 "$file" \
      \( \( "$LOGO_1" -trim +repage -resize "${logo_size}x${logo_size}" \
            -background none -gravity center -extent "${logo_size}x${logo_size}" \) \
         \( -size "${gap}x${logo_size}" xc:none \) \
         \( -size "${separator_width}x${logo_size}" xc:white \) \
         \( -size "${gap}x${logo_size}" xc:none \) \
         \( "$LOGO_2" -trim +repage -resize "${logo_size}x${logo_size}" \
            -background none -gravity center -extent "${logo_size}x${logo_size}" \) \
         -background none -gravity center +append \
         -resize 60% \
         -resize "${max_width}x${max_height}>" \
         -alpha set -channel A -evaluate multiply "$LOGO_OPACITY" +channel \
      \) \
      -gravity SouthEast -geometry +10+10 -composite \
      "WITH_EVENT_LOGO/DRA_EVENT_SIG26_$(printf '%03d' "$idx").jpeg"

   # Send one completion event only after the image has been saved successfully.
   printf 'done\n'
}

# Export configuration for the parallel workers.
export -f process_one
export total LOGO_1 LOGO_2 LOGO_OPACITY

# A single reader updates the bar, so parallel workers cannot lose increments
# or overwrite each other's progress output.
show_progress() {
   local done_count="$1" bar
   printf -v bar '%*s' "$(( done_count * 40 / total ))" ''
   printf '\r[%-40s] %3d%% processed: %*d left: %*d' \
      "${bar// /#}" \
      "$(( done_count * 100 / total ))" \
      "${#total}" "$done_count" \
      "${#total}" "$(( total - done_count ))"
}

# --- EXECUTION ENGINE (The Pipeline) ---
i=1
for file in "${files[@]}"; do
# We use a 'null separator' (\0) to handle filenames that have spaces safely
printf '%s\0%s\0' "$i" "$file"
i=$((i + 1))
done | xargs -0 -n 2 -P "$jobs" bash -euo pipefail -c 'process_one "$@"' _ | (
   done_count=0
   show_progress "$done_count"
   while IFS= read -r completion; do
      done_count=$(( done_count + 1 ))
      show_progress "$done_count"
   done
   printf '\n'
)

# --- CLEANUP ---
printf "\nDone. Processed %d files using %d parallel jobs.\n\n" "$total" "$jobs"
