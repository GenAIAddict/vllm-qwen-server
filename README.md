# Qwen3-VL-8B-Thinking vLLM Server

A complete setup for hosting the Qwen3-VL-8B-Thinking model using vLLM with a beautiful web interface.

## 🎯 What This Project Provides

- **vLLM Server** - High-performance AI model serving
- **Web Chat Interface** - Beautiful, user-friendly chat UI
- **API Testing Tools** - Scripts to test your model
- **Complete Setup** - Everything configured and ready to run

## 🖥️ System Requirements

**IMPORTANT:** The Qwen3-VL-8B-Thinking model requires significant GPU memory:
- **Model weights:** ~16.6 GB
- **KV cache:** Additional memory needed
- **Total GPU memory needed:** ~24 GB minimum

**Recommended Hardware:**
- RTX 3090 (24GB) ✅
- RTX 4090 (24GB) ✅
- A100 (40GB/80GB) ✅

## 🚀 Quick Start Guide

### Step 1: Setup Environment
```bash
# Make scripts executable
chmod +x setup.sh

# Install dependencies (run once)
./setup.sh
```

### Step 2: Start the AI Model Server
```bash
# Make server script executable
chmod +x start_server.sh

# Start vLLM server (keep this running)
./start_server.sh
```
**✅ Server will be running at:** `http://localhost:8000`

### Step 3: Test the Model (Optional)
```bash
# Test the model API
python test_model.py
```

### Step 4: Start Web Interface
```bash
# Start the web UI (in a new terminal)
python web_ui.py
```
**✅ Web UI will be available at:** `http://localhost:5000`

## 📋 Complete Running Sequence

1. **Terminal 1 - Start AI Server:**
   ```bash
   cd /path/to/your/project
   source .venv/bin/activate
   ./start_server.sh
   ```
   *(Keep this running - this is your AI model)*

2. **Terminal 2 - Start Web UI:**
   ```bash
   cd /path/to/your/project
   source .venv/bin/activate
   python web_ui.py
   ```
   *(Keep this running - this is your web interface)*

3. **Open Browser:**
   - Go to: `http://localhost:5000`
   - Start chatting with your AI model!

## 🎮 Usage Options

### Option 1: Web Interface (Recommended)
- **URL:** `http://localhost:5000`
- Beautiful chat interface with file upload support
- **Upload images** (PNG, JPG, GIF, etc.) for visual analysis
- **Upload PDF documents** for text extraction and analysis
- Drag & drop file uploading
- Adjustable settings (temperature, max tokens, thinking budget)
- Shows model's "thinking" process
- Mobile-friendly design

### Option 2: Direct API Calls
```bash
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen3-VL-8B-Thinking",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 500
  }'
```

### Option 3: Python API
```python
import requests

response = requests.post("http://localhost:8000/v1/chat/completions", json={
    "model": "Qwen3-VL-8B-Thinking",
    "messages": [{"role": "user", "content": "Your question here"}],
    "max_tokens": 500
})

print(response.json()['choices'][0]['message']['content'])
```

## 📁 Project Structure

```
├── setup.sh              # Environment setup script
├── start_server.sh        # vLLM server startup script
├── web_ui.py             # Web interface server
├── test_model.py         # API testing script
├── requirements.txt      # Python dependencies
├── templates/
│   └── chat.html         # Web UI template
└── README.md            # This file
```

## 🔧 Model Configuration

- **Model:** Qwen/Qwen3-VL-8B-Thinking
- **Model Size:** ~16.6 GB
- **Context Length:** 7,360 tokens (optimized for 24GB GPU)
- **Server Port:** 8000
- **Web UI Port:** 5000
- **GPU Memory Utilization:** 98%

## 🛠️ Troubleshooting

### "No available memory for cache blocks" Error
1. **Check GPU memory:** `nvidia-smi`
2. **Ensure using correct GPU:** Check `CUDA_VISIBLE_DEVICES=1` in `start_server.sh`
3. **Reduce context length:** Lower `CONTEXT_LENGTH` in `start_server.sh`
4. **Lower GPU utilization:** Reduce `--gpu-memory-utilization` value

### Web UI Not Loading
1. **Check vLLM server:** Ensure `./start_server.sh` is running
2. **Check ports:** Make sure ports 5000 and 8000 are available
3. **Check browser:** Go to `http://localhost:5000` (not 127.0.0.1)

### Model Loading Slowly
- **First run:** Model downloads ~17GB (takes time)
- **Subsequent runs:** Much faster (model cached locally)

## 🎯 Features

### vLLM Server Features:
- ✅ High-performance inference
- ✅ OpenAI-compatible API
- ✅ Optimized for RTX 3090
- ✅ Automatic GPU detection
- ✅ Memory optimization

### Web UI Features:
- ✅ Beautiful, modern interface
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