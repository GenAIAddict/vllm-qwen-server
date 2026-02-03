#!/bin/bash
# Setup script for Qwen3-VL-8B-Instruct model using conda

echo "Creating conda environment 'Qwen-Env' (if it doesn't already exist)..."
if ! conda env list | grep -q "^Qwen-Env"; then
	conda create -n Qwen-Env python=3.10 -y
else
	echo "Conda env 'Qwen-Env' already exists. Skipping create." 
fi

echo "Activating conda environment..."
# Use conda run for non-interactive shells; this script should work whether run in a login shell or not.
echo "You may be prompted to allow conda to initialize the shell if this was not done."
conda activate Qwen-Env

echo "Installing PyTorch (via conda) with CUDA support (pytorch-cuda=12.1 by default)..."
# Use conda install for better compatibility with system CUDA drivers and dependencies
conda install -n Qwen-Env pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y || \
	{ echo "conda install for pytorch failed: falling back to pip wheel for CPU/CUDA (may not have GPU support)"; }

echo "Installing CUDA development headers (optional) via conda-forge..."
conda install -n Qwen-Env cudatoolkit-dev=12.1 -c conda-forge -y || echo "cudatoolkit-dev installation skipped or failed; that's OK for normal use"

echo "Installing other Python dependencies from requirements.txt..."
conda run -n Qwen-Env python -m pip install -r requirements.txt || echo "pip install -r requirements.txt failed; try running it manually to see errors"

echo "Installing flashinfer (optional - may fail if CUDA headers are missing)..."
conda run -n Qwen-Env python -m pip install flashinfer-python || echo "Warning: flashinfer installation failed. vLLM will use PyTorch fallback."

echo "Verifying installations: python, torch, and vllm..."
conda run -n Qwen-Env python - <<'PY'
import importlib, sys
print('Python executable:', sys.executable)
print('Python version:', sys.version)
print('torch installed:', importlib.util.find_spec('torch') is not None)
print('vllm installed:', importlib.util.find_spec('vllm') is not None)
try:
	import torch
	print('torch version:', torch.__version__)
	print('CUDA available:', torch.cuda.is_available())
	print('GPU count:', torch.cuda.device_count())
except Exception as e:
	print('torch import error:', e)
PY

echo "If torch or vllm is missing, re-run the script or run:"
echo "  conda activate Qwen-Env"
echo "  conda install -n Qwen-Env pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia"
echo "  pip install -r requirements.txt"
echo "Setup finished. To start the server, activate the environment and run './start_server.sh'"