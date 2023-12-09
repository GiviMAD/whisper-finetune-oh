#!/bin/bash
set -e
source env_whisper-finetune/bin/activate
echo " --------    Creating records dataset    -------- "
./whisper-finetune-oh/convert_oh_whisper_records.sh
echo " --------    Running training    -------- "
EXTRA_ARGS=""
if [ "$CPU_ONLY" = true ] ; then
    EXTRA_ARGS="$EXTRA_ARGS --cpu_only True"
fi
torchrun ./whisper-finetune-oh/train/fine-tune_on_custom_dataset.py $EXTRA_ARGS \
--model_name $PARAM_MODEL_NAME --sampling_rate 16000 --language $PARAM_LANGUAGE --num_proc $PARAM_NUM_PROC \
--train_strategy $PARAM_TRAIN_STRATEGY --learning_rate $PARAM_LEARNING_RATE --warmup $PARAM_WARNUP --train_batchsize $PARAM_TRAIN_BATCHSIZE \
--eval_batchsize $PARAM_EVAL_BATCHSIZE --num_epochs $PARAM_EPOCHS --num_steps $PARAM_NUM_STEPS --resume_from_ckpt $PARAM_RESUME_CHECKPOINT --output_dir ./op_dir_epoch \
--train_datasets ./whisper-finetune-oh/custom_data/oh_dataset --eval_datasets ./whisper-finetune-oh/custom_data/oh_dataset
echo " --------    Creating ggml model    -------- "
LAST_CHECKPOINT=$(ls ./op_dir_epoch/ | grep checkpoint- | tail -1)
cp ./op_dir_epoch/$LAST_CHECKPOINT/* ./op_dir_epoch
python3 ./whisper.cpp/models/convert-h5-to-ggml.py ./op_dir_epoch ./whisper /output
