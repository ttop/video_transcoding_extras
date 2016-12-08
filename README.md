# Video Transcoding Extras 

## Introduction

This is a collection of scripts I wrote to do some batch processing in conjunction with [Don Melton's excellent video transcoding scripts](https://github.com/donmelton/video_transcoding).

These were developed on macOS in a unix shell.

Perhaps you'll find them useful.


## `batch.sh`

This is a variation on the example provided in [Don's README](https://github.com/donmelton/video_transcoding/blob/master/README.md). 

It expects to find `queue.txt`, where each line contains a path to an `.mkv` file to be transcoded. 

If you have a directory with a bunch of `.mkv` files you wish to process, an easy way to create this file is as follows:

`find /Volumes/avclub-1/ripped/*.mkv -type f > queue.txt`

Substitute your own path to the directory of your choice.

If the source filename for a video ends with the suffix `- raw.mkv`, the script will strip the `- raw` portion suffix and use the resulting filename as the output file.

If the source filename does *not* end with the `- raw` suffix, it will append `-encode.mkv` as the output file's suffix.

The script then looks for a corresponding crop file in a subdirectory of the current directory named `Crops`. The crop filename it is looking for is the same as the source filename but with a `.txt` extension. It only processes files which have a corresponding crop file. See Don's `transcode-video` usage docs for more information.

When transcoding is complete, `convert-video` is called to make an mp4 copy of the mkv. The source and the two output files are moved to a `Completed Media/sort` subdirectory where you can then decide what to do with them. The log file is moved to a `logs` subdirectory.


## `generate-crops.sh`

This script attempts to generate a crop file using `detect-crop` for each `.mkv` file in the current directory, except for files whose filename begins with "title", as this is a common default filename used on discs. It places the crops in a `Crops` subdirectory. If `detect-crop` has a conflict, it instead writes a "crop options" file to the `Crops/fix` directory. This file contains the different mplayer options you can use to preview the conflicting cropping recommendations. It also creates a placeholder crop file in this directory where you can enter the crops values you decide to use.

If an existing crop file or crop conflict file is detected, the script will not attempt to detect the crop again.
