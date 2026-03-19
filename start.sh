
#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$ROOT_DIR/src"
VENV_PYTHON="$ROOT_DIR/.venv/bin/python"
APP_MODULE="${APP_MODULE:-main:app}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8000}"
LOG_FILE="$ROOT_DIR/app.log"
PID_FILE="$ROOT_DIR/app.pid"

cd "$ROOT_DIR"

echo "===== 项目目录: $ROOT_DIR ====="

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  CURRENT_BRANCH="$(git branch --show-current)"
  echo "===== 拉取最新代码: ${CURRENT_BRANCH} ====="
  git pull --ff-only origin "$CURRENT_BRANCH"
fi

if [ ! -x "$VENV_PYTHON" ]; then
  echo "错误: 未找到虚拟环境 Python: $VENV_PYTHON"
  echo "请先在服务端创建虚拟环境并安装依赖。"
  exit 1
fi

if [ ! -d "$APP_DIR" ]; then
  echo "错误: 未找到应用目录: $APP_DIR"
  exit 1
fi

echo "===== 安装/更新依赖 ====="
"$VENV_PYTHON" -m pip install -r requirements.txt

if [ -f "$PID_FILE" ]; then
  OLD_PID="$(cat "$PID_FILE")"
  if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
    echo "===== 停止旧进程: $OLD_PID ====="
    kill "$OLD_PID"
    sleep 1
  fi
  rm -f "$PID_FILE"
fi

echo "===== 清理旧的 uvicorn 进程 ====="
pkill -f "uvicorn $APP_MODULE" 2>/dev/null || true

echo "===== 启动 FastAPI 服务 ====="
nohup "$VENV_PYTHON" -m uvicorn --app-dir "$APP_DIR" "$APP_MODULE" --host "$HOST" --port "$PORT" > "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"

echo "服务已启动"
echo "PID: $(cat "$PID_FILE")"
echo "日志: $LOG_FILE"
