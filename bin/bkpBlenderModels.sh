#!/bin/bash

trash -v blenderModels.tar.7z blenderModels.tar&&:
IFS=$'\n' read -d '' -r -a astrList < <(find -iname "*.blend" |egrep -v "copybuffer|quit|autosave");
tar -vcf "blenderModels.tar" "${astrList[@]}";
7z a blenderModels.tar.7z blenderModels.tar
