
#!/bin/bash

echo "===== 开始部署 ====="

git pull origin main

source .venv/bin/activate

pip install -r requirements.txt

echo "===== 杀掉旧进程 ====="
pkill -f "uvicorn main:app"

echo "===== 后台启动 ====="
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > app.log 2>&1 &
