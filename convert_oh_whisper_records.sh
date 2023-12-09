#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
records_folder=${1:-"/oh_whisper_records"}
data_folder=$SCRIPTPATH/custom_data/oh_data
dataset_folder=$SCRIPTPATH/custom_data/oh_dataset
audio_file=$data_folder/audio_paths
text_file=$data_folder/text
mkdir -p $data_folder
mkdir -p $dataset_folder
rm -rf $data_folder/*
rm -rf $dataset_folder/*
file_counter=0
for wav_file in $records_folder/*.wav
do 
    file_counter=$((file_counter+1))
    prop_file="${wav_file%*.wav}.props"
    text_line=$(cat $prop_file | grep transcription=)
    text="${text_line#"transcription="}"
    file_id="utt_id_$(printf "%04d\n" $file_counter)"
    echo "$file_id $wav_file" >> "$audio_file"
    echo "$file_id $text" >> "$text_file"
done

python3 $SCRIPTPATH/custom_data/data_prep.py --source_data_dir $data_folder --output_data_dir $dataset_folder