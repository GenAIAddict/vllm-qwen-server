#!/bin/bash
# Wrapper script to properly set CUDA environment before any Python initialization

# CRITICAL: Set CUDA environment FIRST, before any other operations
export CUDA_DEVICE_ORDER=PCI_BUS_ID
export CUDA_VISIBLE_DEVICES=1

# Clear any existing CUDA context
unset CUDA_CACHE_PATH
export CUDA_CACHE_DISABLE=1

echo "CUDA Environment:"
echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
echo "CUDA_DEVICE_ORDER: $CUDA_DEVICE_ORDER"

# Now run the actual server script
exec ./start_server.sh