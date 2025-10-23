#!/bin/bash
set -euo pipefail

export CUDA_DEVICE_ORDER=PCI_BUS_ID
export CUDA_VISIBLE_DEVICES=1

source .venv_gptoss/bin/activate

echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU count: {torch.cuda.device_count()}')" || echo "Warning: CUDA check failed"

export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

# Use the quantized model variant for Q4-like compression
MODEL=${MODEL:-'unsloth/gpt-oss-20b-GGUF'}
PORT=${PORT:-8001}  # Different port to avoid conflict

vllm serve "$MODEL" \
    --host 0.0.0.0 \
    --port "$PORT" \
    --max-model-len 1024 \
    --gpu-memory-utilization 0.8 \
    --max-num-seqs 1 \
    --disable-log-requests \
    --trust-remote-code \
    --skip-tokenizer-init \
    --cpu-offload-gb 10