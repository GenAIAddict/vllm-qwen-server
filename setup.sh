#!/bin/bash
# Setup script for Qwen3-VL-8B-Instruct model

echo "Creating Python virtual environment..."
python3 -m venv .venv
source .venv/bin/activate

echo "Upgrading pip..."
pip install --upgrade pip

echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

echo "Installing flashinfer..."
pip install flashinfer-jit-cache --index-url https://flashinfer.ai/whl/cu128

echo "Setup complete! Run './start_server.sh' to start the vLLM server."