#!/bin/bash
# Setup script for GPT-OSS-20B model

echo "Installing uv if not present..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

echo "Creating Python virtual environment for GPT-OSS..."
uv venv --python 3.12 .venv_gptoss

echo "Installing vLLM..."
source .venv_gptoss/bin/activate
uv pip install vllm

echo "Installing additional dependencies..."
uv pip install qwen-vl-utils==0.0.14

echo "Installing flashinfer..."
pip install flashinfer-jit-cache --index-url https://flashinfer.ai/whl/cu128

echo "Setup complete! Run './start_gptoss.sh' to start the vLLM server for GPT-OSS."