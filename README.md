# vLLM Qwen Server

A complete setup for hosting Qwen vision-language models using vLLM with high-performance GPU serving capabilities.

## 🎯 What This Project Provides

- **Qwen3-VL-8B-Instruct Server** - Multi-model serving with vLLM on primary GPU
- **GPT-OSS-20B Alternative** - Quantized model option on secondary GPU
- **Dual Conda Environments** - Separate isolated environments for each model
- **Environment Management** - Flexible GPU allocation and performance configuration
- **Production Ready Scripts** - Comprehensive startup, shutdown, and wrapper scripts

## 🖥️ System Requirements

### GPU Requirements

**For Qwen3-VL-8B-Instruct:**
- **Model weights:** ~16.6 GB
- **KV cache:** Additional memory needed
- **Total GPU memory needed:** ~24 GB minimum

**For GPT-OSS-20B-GGUF (Quantized):**
- **Model weights:** ~10-12 GB (quantized)
- **Total GPU memory needed:** ~12-16 GB

**Recommended Hardware:**
- RTX 3090 (24GB) - Single model ✅
- RTX 4090 (24GB) - Single model ✅
- A100 (40GB) - Both models simultaneously ✅
- A100 (80GB) - Both models with headroom ✅
- Multi-GPU setup - One GPU per model recommended

### Software Requirements
- CUDA 11.8+
- Python 3.10+
- vLLM latest version
- PyTorch with CUDA support

## 📁 Project Structure

```
vllm-qwen-server/
├── setup.sh                    # Setup primary environment for Qwen3-VL
├── setup_gptoss.sh            # Setup secondary environment for GPT-OSS
├── start_server.sh            # Start Qwen3-VL server
├── start_gptoss.sh            # Start GPT-OSS server
├── start_server_wrapper.sh    # Wrapper with CUDA environment setup
├── stop_server.sh             # Graceful server shutdown utility
├── requirements.txt           # Python dependencies
├── uploads/                   # Directory for file uploads
├── Qwen-Env/                 # Primary conda environment (auto-created)
└── vllm-gptoss-env/          # Secondary conda environment (auto-created)
```

## 🚀 Quick Start Guide

### Step 0: Clone the Repository
```bash
# Clone the project from GitHub
git clone https://github.com/GenAIAddict/vllm-qwen-server.git
cd vllm-qwen-server
```

### Step 1: Setup Environment(s)

#### For Qwen3-VL-8B-Instruct (Primary):
```bash
# Make setup script executable
chmod +x setup.sh

# Install dependencies and create conda environment
# Install dependencies and create conda environment
./setup.sh
```

#### For GPT-OSS-20B (Optional, requires second GPU):
```bash
# Create conda environment for GPT-OSS
conda create -n vllm-gptoss-env python=3.10 -y
conda activate vllm-gptoss-env

# Install dependencies
pip install vllm transformers
```

### Step 2: Start the Server(s)

#### Start Qwen3-VL-8B-Instruct Server
```bash
# Make server scripts executable
chmod +x start_server.sh start_server_wrapper.sh

# Option 1: Direct start
./start_server.sh

# Option 2: Start with wrapper (recommended for proper CUDA setup)
./start_server_wrapper.sh
```
**✅ Server will be running at:** `http://localhost:8000`

**Configuration options (set before running):**
```bash
# Custom model (default: Qwen/Qwen3-VL-8B-Instruct)
export MODEL_ARG="Qwen/Qwen3-VL-8B-Instruct"

# Custom served model name (default: Qwen3-VL-8B-Instruct)
export SERVED_NAME="Qwen3-VL-8B-Instruct"

# Context length (default: 4096)
export CONTEXT_LENGTH=4096

# GPU memory utilization (default: 0.98, range: 0.0-1.0)
export GPU_MEM_UTIL=0.98

# Max concurrent sequences (default: 1)
export MAX_NUM_SEQS=1

# Server port (default: 8000)
export PORT=8000

# GPU to use (default: 1)
export CUDA_VISIBLE_DEVICES=0
```

#### Start GPT-OSS-20B Server (Optional)
```bash
chmod +x start_gptoss.sh
./start_gptoss.sh
```
**✅ Server will be running at:** `http://localhost:8001`

### Step 3: Stop the Server(s)

Use the comprehensive stop script:
```bash
chmod +x stop_server.sh

# Stop by port (default port 8000)
./stop_server.sh --port 8000

# Stop by served model name
./stop_server.sh --model Qwen3-VL-8B-Instruct

# Stop by PID
./stop_server.sh --pid 12345

# Force kill immediately
./stop_server.sh --port 8000 --force
```

### Step 4: Start Web Interface
```bash
# Start the web UI (in a new terminal)
python web_ui.py
```
**✅ Web UI will be available at:** `http://localhost:5000`

## � Advanced Configuration

### Environment Variables Reference

**Qwen3-VL Server (Qwen-Env):**
```bash
MODEL_ARG              # Model identifier (default: Qwen/Qwen3-VL-8B-Instruct)
SERVED_NAME           # Name exposed by API (default: Qwen3-VL-8B-Instruct)
CONTEXT_LENGTH        # Max token context (default: 4096)
GPU_MEM_UTIL          # GPU memory percentage (default: 0.98)
MAX_NUM_SEQS          # Concurrent requests (default: 1)
PORT                  # Server port (default: 8000)
CUDA_VISIBLE_DEVICES  # GPU device number (default: 1)
```

**GPT-OSS Server (vllm-gptoss-env):**
```bash
MODEL                 # Model identifier (default: unsloth/gpt-oss-20b-GGUF)
PORT                  # Server port (default: 8001)
CUDA_VISIBLE_DEVICES  # GPU device number (default: 1)
```

### Using Different GPUs

Start on GPU 0:
```bash
export CUDA_VISIBLE_DEVICES=0
./start_server.sh
```

Start on GPU 1 (default):
```bash
export CUDA_VISIBLE_DEVICES=1
./start_server.sh
```

Use multiple GPUs:
```bash
export CUDA_VISIBLE_DEVICES=0,1
./start_server.sh
```

## 🎮 API Usage Examples

### Option 1: Using cURL
```bash
# Chat completion
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen3-VL-8B-Instruct",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 500
  }'
```

### Option 2: Using Python Requests
```python
import requests

response = requests.post("http://localhost:8000/v1/chat/completions", json={
    "model": "Qwen3-VL-8B-Instruct",
    "messages": [{"role": "user", "content": "Your question here"}],
    "max_tokens": 500
})

print(response.json()['choices'][0]['message']['content'])
```

### Option 3: Using OpenAI Python SDK
```python
from openai import OpenAI

client = OpenAI(api_key="dummy", base_url="http://localhost:8000/v1")

response = client.chat.completions.create(
    model="Qwen3-VL-8B-Instruct",
    messages=[{"role": "user", "content": "Your question"}],
    max_tokens=500
)

print(response.choices[0].message.content)
```

## 🛠️ Troubleshooting

### "CUDA out of memory" Error
1. **Check GPU memory:** `nvidia-smi`
2. **Verify GPU selection:** Ensure `CUDA_VISIBLE_DEVICES` is correct
3. **Reduce memory utilization:** Lower `GPU_MEM_UTIL` (e.g., 0.9 instead of 0.98)
4. **Reduce context length:** Lower `CONTEXT_LENGTH` (e.g., 2048 instead of 4096)
5. **Reduce concurrent requests:** Lower `MAX_NUM_SEQS`

### Server Won't Start
1. **Check CUDA availability:** `python -c "import torch; print(torch.cuda.is_available())"`
2. **Verify conda environment:** `conda activate Qwen-Env`
3. **Check dependencies:** `pip list | grep vllm`
4. **Check port availability:** `lsof -i :8000` or `netstat -tuln | grep 8000`

### Port Already in Use
```bash
# Find process using port 8000
lsof -i :8000

# Kill the process
kill -9 <PID>

# Or use the stop script
./stop_server.sh --port 8000
```

### Model Loading Slowly
- **First run:** Model downloads from Hugging Face (takes time)
- **Subsequent runs:** Model cached locally (much faster)
- **Cache location:** `~/.cache/huggingface/hub/`

## 📊 Performance Tips

1. **Enable Flash Attention:** Already configured in setup
2. **Use GPU memory utilization near 1.0:** Better throughput
3. **Batch requests:** Use `MAX_NUM_SEQS > 1` if handling multiple requests
4. **Monitor GPU:** Run `nvidia-smi -l 1` in separate terminal

## � Firewall & Network Access

### Local Only (Default)
```bash
# Access from localhost only
http://localhost:8000
```

### Network Access
Edit `start_server.sh` to change:
```bash
--host 0.0.0.0    # Currently set to accept all interfaces
```

### Behind Proxy/Nginx
Configure your reverse proxy to forward requests to `http://localhost:8000`

## 📝 Model Information

### Qwen3-VL-8B-Instruct
- **Publisher:** Alibaba Cloud
- **Model Size:** ~16.6 GB
- **Parameters:** 8 Billion
- **Capabilities:** Vision, Language, Instruction-following
- **License:** Check [Qwen License](https://huggingface.co/Qwen/Qwen3-VL-8B-Instruct)

### GPT-OSS-20B-GGUF
- **Model Size:** ~10-12 GB (quantized)
- **Parameters:** 20 Billion
- **Format:** GGUF (quantized)
- **Purpose:** Alternative lightweight option

## 📚 Resources

- [vLLM Documentation](https://docs.vllm.ai/)
- [Qwen Models](https://huggingface.co/Qwen)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)
- [CUDA Setup Guide](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/)
- ✅ Real-time status monitoring
- ✅ Adjustable AI parameters (temperature, max tokens)
- ✅ **Thinking Budget Control** - Adjust how much the AI "thinks"
- ✅ **File Upload Support** - Upload images and PDF documents
- ✅ **Image Analysis** - Vision capabilities for uploaded images
- ✅ **Smart PDF Processing** - Handles both text-based and image-based PDFs
- ✅ **PDF Text Extraction** - Extract text from text-based PDFs
- ✅ **PDF Visual Analysis** - Convert image-based PDFs to images for direct VL model analysis
- ✅ **Drag & Drop Interface** - Easy file uploading
- ✅ Mobile-responsive design
- ✅ Shows model "thinking" process visually
- ✅ Auto-resizing input field

## 🔗 Endpoints

- **vLLM Server:** `http://localhost:8000`
- **Web Interface:** `http://localhost:5000`
- **API Health:** `http://localhost:8000/health`
- **Available Models:** `http://localhost:8000/v1/models`

## 💡 Tips

1. **Keep both terminals running** - One for vLLM server, one for web UI
2. **First startup takes longer** - Model needs to download initially
3. **Use web interface** - Much easier than API calls
4. **Upload files for analysis**:
   - **Images**: PNG, JPG, GIF, BMP, WebP (max 16MB)
   - **Text-based PDFs**: Text extracted automatically
   - **Image-based PDFs**: Converted to images for direct VL model analysis
   - **Scanned documents**: Visual analysis by VL model (no OCR needed)
   - **Drag & drop** files directly onto the upload area
5. **Adjust temperature** - Lower (0.3) for focused responses, higher (0.9) for creative
6. **Thinking Budget Control** - Higher values = more detailed reasoning:
   - **Low (128)**: Quick, basic thinking
   - **Medium (256)**: Balanced reasoning
   - **High (512)**: Detailed analysis (recommended)
   - **Very High (1024)**: Deep reasoning
   - **Maximum (2048)**: Extensive thinking process
7. **Monitor GPU usage** - Use `nvidia-smi` to check memory usage

## 🎉 You're Ready!

Your Qwen3-VL-8B-Thinking model is now ready to use with a beautiful web interface. The model shows its "thinking" process, making it perfect for reasoning tasks, problem-solving, and creative conversations!



------------------------
# To run the TPS measurement with the updated prompt, use:

./measure_tps.py --url http://127.0.0.1:8000/v1/chat/completions --prompt "write a short story about a cat of 500 words" --duration 10 --parallel 4

-----------------
# To start the server with the GGUF model, use the following command:

export MODEL_ARG="/home/retriv/.cache/huggingface/hub/models--Qwen3-Coder-30B/qwen3-coder-30b-a3b-instruct-q4_k_s.gguf" && ./start_server.sh


# To start the server with Qwen3-VL-30B-A3B-Instruct-AWQ GGUF model, use the following command:
export MODEL_ARG="/home/retriv/.cache/huggingface/hub/models--QuantTrio--Qwen3-VL-30B-A3B-Instruct-AWQ" && SERVED_NAME="Qwen3-VL-30B-A3B-Instruct-AWQ" && ./start_server.sh

# To start the server with Qwen3-VL-8B-Instruct , use the following command:
export MODEL_ARG="/home/retriv/.cache/huggingface/hub/models--Qwen--Qwen3-VL-8B-Instruct" && SERVED_NAME="Qwen3-VL-8B-Instruct" && ./start_server.sh

---------------------------
# To clear the torch compile cache, run:
# preferred: your helper if present
./stop_server.sh --port 8000

# fallback (be careful: kills any running 'vllm serve' processes)
pkill -f "vllm serve"

# Clear the torch compile cache
rm -rf ~/.cache/vllm/torch_compile_cache/*

----------------------
# Contents of start_server.sh
vllm serve \
        "Qwen/Qwen3-VL-8B-Instruct" \
        --served-model-name "Qwen3-VL-8B-Instruct" \
        --swap-space 16 \
        --max-num-seqs 2 \
        --max-model-len 8096 \
        --gpu-memory-utilization 0.98 \
        --trust-remote-code \
        --disable-log-requests \
        --host 0.0.0.0 \
        --port 8000 \
        --block-size 16

        ---------------------------

        and why does it say this ? are there any issues because flashinfer isn't available ?

<<
(EngineCore_DP0 pid=30785) WARNING 10-18 23:43:59 [topk_topp_sampler.py:66] FlashInfer is not available. Falling back to the PyTorch-native implementation of top-p & top-k sampling. For the best performance, please install FlashInfer.
>>

How do I install FlashInfer ?