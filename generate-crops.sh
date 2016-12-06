#!/usr/bin/env bash

#    ** Goals **
#
#    * Auto-generate Crops files for each mkv in the user’s current directory
#    * If detect-crop fails, put detect-crop output in a text file with same 
#	   filename prefix but with a “ - crop options.txt” suffix
#    * Skip if the filename is a generic “title.*.mkv” file
#    * Skip if an existing crops or conflict file already exists

# Get filenames matching *.mkv but don't start with “title” 
my_filenames=()
while IFS= read -r line; do
    my_filenames+=( "$line" )
done < <( ls *.mkv | grep -v title )

# Create the Crops directory if necessary

mkdir -p "Crops/fix"

for fullname in "${my_filenames[@]}"
do
	echo "${fullname}"

	filename_only=${fullname%.*} # get filename without extension
	successful_crop_detect_filename="Crops/${filename_only}.txt"
	failed_crop_detect_filename="Crops/fix/${filename_only} - crop options.txt"

	placeholder_crop_detect_filename="Crops/fix/${filename_only}.txt"

	if [ -f "${successful_crop_detect_filename}" ]; then 
		echo "  A crop file already exists, skipping."
	elif [ -f "${failed_crop_detect_filename}" ]; then
		echo "  A crop conflict file already exists, skipping."
	else
		detect_crop_output=$(detect-crop --quiet --values-only "$fullname")
		if [ "$?" = "0" ]; then # successfully detected crop
			echo $detect_crop_output > "${successful_crop_detect_filename}"
			echo  "  Crop detected: wrote ${successful_crop_detect_filename}"
		else # crop conflict detected
			detect-crop --quiet "${fullname}" > "${failed_crop_detect_filename}"
			touch "${placeholder_crop_detect_filename}"
			echo "  Crop conflict: wrote ${failed_crop_detect_filename}"
		fi
	fi
done
