#!/usr/bin/env bash

readonly work="$(cd "$(dirname "$0")" && pwd)"
readonly queue="$work/queue.txt"
readonly crops="$work/Crops"
readonly completed="$work/Completed Media/sort"

input="$(sed -n 1p "$queue")"

while [ "$input" ]; do
    title_name="$(basename "$input" | sed 's/\.[^.]*$//')"
    crop_file="$crops/${title_name}.txt"

    echo $title_name
    converted="${title_name}.mp4"
    if [[ "$title_name" =~ .*-\ *raw ]]; then
        # filename ends in "- raw", strip this suffix for output file
        title_wo_raw="$(echo -e "${title_name/- raw}" | sed -e 's/[[:space:]]*$//')"
        outfile="${title_wo_raw}.mkv"
        converted="${title_wo_raw}.mp4"
    else
        # filename doesn't end in "- raw", add an "-encode" suffix for output file
        outfile="${title_name}-encode.mkv"
        converted="${title_name}.mp4"
    fi

    if [ -f "$crop_file" ]; then
        crop_option="--crop $(cat "$crop_file")"
        sed -i '' 1d "$queue" || exit 1
        transcode-video $crop_option "$input" --output "$outfile" 
        convert-video "$outfile"
        mv "$input" "$completed"
        mv "$outfile" "$completed"
        mv "$converted" "$completed"
        mv "${outfile}.log" "${work}/logs"
        input="$(sed -n 1p "$queue")"
    else
        # Only process if a crop file is present
        echo "No crop file, skipping ${title_name}"
    fi
done