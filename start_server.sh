#!/bin/bash
set -euo pipefail

export CUDA_DEVICE_ORDER=PCI_BUS_ID
export CUDA_VISIBLE_DEVICES=1


if [ -z "${CUDA_HOME:-}" ] && [ -d /usr/local/cuda-12.8 ]; then
    export CUDA_HOME=/usr/local/cuda-12.8
elif [ -z "${CUDA_HOME:-}" ] && [ -d /usr/local/cuda ]; then
    export CUDA_HOME=/usr/local/cuda
fi

if [ -z "${CUDACXX:-}" ] && [ -n "${CUDA_HOME:-}" ] && [ -x "${CUDA_HOME}/bin/nvcc" ]; then
    export CUDACXX="${CUDA_HOME}/bin/nvcc"
fi

if [ -d /usr/lib/x86_64-linux-gnu ]; then
    export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}"
fi

if [ -n "${CUDA_HOME:-}" ]; then
    export PATH="${CUDA_HOME}/bin:${PATH}"
    export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH:-}"
fi

# Fix for GLIBCXX_3.4.32 not found error in Conda environments
if [ -f /usr/lib/x86_64-linux-gnu/libstdc++.so.6 ]; then
    export LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6:${LD_PRELOAD:-}"
fi

echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU count: {torch.cuda.device_count()}')" || echo "Warning: CUDA check failed"

MODEL_ARG=${MODEL_ARG:-'Qwen/Qwen3-VL-8B-Instruct'}
SERVED_NAME=${SERVED_NAME:-'Qwen3-VL-8B-Instruct'}

#While using a GGUF model, always download the model from Hugging Face and then pass on the path to the model as the MODEL_ARG because GGUF models need to have the GGUF file in the same directory as the model.
#MODEL_ARG=${MODEL_ARG:-'/home/retriv/.cache/huggingface/hub/models--Qwen3-Coder-30B/qwen3-coder-30b-a3b-instruct-q4_k_s.gguf'}
#SERVED_NAME=${SERVED_NAME:-'Qwen3-Coder-30B-A3B-Instruct-GGUF'}

#MODEL_ARG=${MODEL_ARG:-'QuantTrio/Qwen3-VL-30B-A3B-Instruct-AWQ'}
#SERVED_NAME=${SERVED_NAME:-'Qwen3-VL-30B-A3B-Instruct-AWQ'}

CONTEXT_LENGTH=${CONTEXT_LENGTH:-2592}
GPU_MEM_UTIL=${GPU_MEM_UTIL:-0.95} # Set back to 0.95 now that environment is fixed
MAX_NUM_SEQS=${MAX_NUM_SEQS:-1}
PORT=${PORT:-6000}

# Ensure all variables are set
set +u  # Temporarily disable unbound variable check to verify all variables are set
echo "Configuration:"
echo "  Model: $MODEL_ARG"
echo "  Served Name: $SERVED_NAME"
echo "  Context Length: $CONTEXT_LENGTH"
echo "  GPU Memory Utilization: $GPU_MEM_UTIL"
echo "  Max Num Seqs: $MAX_NUM_SEQS"
echo "  Port: $PORT"
set -u  # Re-enable unbound variable check

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