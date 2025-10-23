#!/bin/bash
set -euo pipefail

export CUDA_DEVICE_ORDER=PCI_BUS_ID
export CUDA_VISIBLE_DEVICES=1

source .venv/bin/activate

echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU count: {torch.cuda.device_count()}')" || echo "Warning: CUDA check failed"

MODEL_ARG=${MODEL_ARG:-'Qwen/Qwen3-VL-8B-Instruct'}
SERVED_NAME=${SERVED_NAME:-'Qwen3-VL-8B-Instruct'}
CONTEXT_LENGTH=${CONTEXT_LENGTH:-4096}
GPU_MEM_UTIL=${GPU_MEM_UTIL:-0.98}
MAX_NUM_SEQS=${MAX_NUM_SEQS:-1}
PORT=${PORT:-8000}

python -m vllm.entrypoints.openai.api_server \
    --served-model-name "$SERVED_NAME" \
    --model "$MODEL_ARG" \
    --max-model-len "$CONTEXT_LENGTH" \
    --gpu-memory-utilization "$GPU_MEM_UTIL" \
    --max-num-seqs "$MAX_NUM_SEQS" \
    --disable-log-requests \
    --trust-remote-code \
    --host 0.0.0.0 \
    --port "$PORT"