#!/usr/bin/env bash
# Stop a running vLLM server by PID, port, or served-model-name.
# Usage:
#   ./stop_server.sh --pid 12345
#   ./stop_server.sh --port 8000
#   ./stop_server.sh --model Qwen3-VL-8B-Thinking
#   ./stop_server.sh --port 8000 --force   # escalate to SIGKILL immediately

set -euo pipefail

print_usage() {
  cat <<EOF
Usage: $0 [--pid PID] [--port PORT] [--model NAME] [--force]

Stop a running vLLM server. Identification priority: PID > port > model name.
By default the script sends SIGINT, waits, then SIGTERM, and finally SIGKILL if --force
or if the process doesn't exit after the normal escalation.

Examples:
  $0 --port 8000
  $0 --model Qwen3-VL-8B-Thinking
  $0 --pid 12345 --force
EOF
}

PID=""
PORT=""
MODEL=""
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pid)
      PID="$2"; shift 2;;
    --port)
      PORT="$2"; shift 2;;
    --model)
      MODEL="$2"; shift 2;;
    --force)
      FORCE=1; shift;;
    -h|--help)
      print_usage; exit 0;;
    *)
      echo "Unknown arg: $1"; print_usage; exit 2;;
  esac
done

if [[ -z "$PID" && -z "$PORT" && -z "$MODEL" ]]; then
  echo "Provide --pid, --port or --model" >&2
  print_usage
  exit 2
fi

if [[ -z "$PID" && -n "$PORT" ]]; then
  PID=$(lsof -ti:"$PORT" 2>/dev/null || true)
fi

if [[ -z "$PID" && -n "$MODEL" ]]; then
  # try pgrep for the served-model-name in the command line
  PID=$(pgrep -f "vllm serve .*${MODEL}" || true)
fi

if [[ -z "$PID" ]]; then
  echo "No process found matching the given criteria" >&2
  # Try one last time to find any vLLM related processes if no PID found
  PID=$(pgrep -f "vllm|EngineCore" || true)
  if [[ -z "$PID" ]]; then
    exit 1
  fi
fi

# Also find any associated EngineCore processes
CORE_PIDS=$(pgrep -f "VLLM::EngineCore" || true)
if [[ -n "$CORE_PIDS" ]]; then
  PID="$PID $CORE_PIDS"
fi

echo "Found PID=$PID"

send_sig() {
  local sig=$1
  if kill -$sig "$PID" 2>/dev/null; then
    echo "Sent SIG$sig to $PID"
  else
    echo "Failed to send SIG$sig to $PID (it may have exited)"
  fi
}

is_alive() {
  ps -p "$PID" > /dev/null 2>&1
}

# If force, escalate to SIGKILL immediately
if [[ $FORCE -eq 1 ]]; then
  echo "Force flag set — sending SIGKILL to $PID"
  kill -9 "$PID" 2>/dev/null || true
  sleep 1
  if is_alive; then
    echo "PID $PID still alive after SIGKILL (unexpected)" >&2
    exit 1
  else
    echo "PID $PID killed"; exit 0
  fi
fi

# Normal graceful flow: SIGINT -> wait -> SIGTERM -> wait -> SIGKILL
send_sig 2
sleep 5
if is_alive; then
  echo "PID $PID still alive after SIGINT — sending SIGTERM"
  send_sig 15
  sleep 5
fi

if is_alive; then
  echo "PID $PID still alive after SIGTERM — sending SIGKILL"
  kill -9 "$PID" 2>/dev/null || true
  sleep 1
fi

if is_alive; then
  echo "Failed to stop PID $PID" >&2
  exit 1
else
  echo "PID $PID stopped successfully"
fi

echo "GPU summary (post-stop):"
nvidia-smi --query-gpu=index,name,memory.total,memory.used,memory.free --format=csv,noheader,nounits || true

exit 0
