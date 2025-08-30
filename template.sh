#!/bin/bash
# Node.js App Deployment Script for Ubuntu
# Usage: ./deploy.sh {start|stop|restart|status|logs|deploy}

APP_NAME="my-node-app"
APP_DIR="/var/www/uat_pos/server"
APP_ENTRY="server.js"   # Change if your main file is app.js, index.js etc.
NODE_ENV="production"
LOG_FILE="$APP_DIR/$APP_NAME.log"
PID_FILE="$APP_DIR/$APP_NAME.pid"

start_app() {
  if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "⚠️ $APP_NAME is already running."
    exit 1
  fi
  echo "🚀 Starting $APP_NAME..."
  cd "$APP_DIR" || exit
  NODE_ENV=$NODE_ENV nohup node "$APP_ENTRY" > "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
  echo "✅ $APP_NAME started with PID $(cat $PID_FILE)"
}

stop_app() {
  if [ ! -f "$PID_FILE" ] || ! kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "⚠️ $APP_NAME is not running."
    exit 1
  fi
  echo "🛑 Stopping $APP_NAME..."
  kill -15 $(cat "$PID_FILE")
  rm -f "$PID_FILE"
  echo "✅ $APP_NAME stopped."
}

restart_app() {
  echo "🔄 Restarting $APP_NAME..."
  stop_app
  start_app
}

status_app() {
  if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "✅ $APP_NAME is running with PID $(cat $PID_FILE)"
  else
    echo "⚠️ $APP_NAME is not running."
  fi
}

show_logs() {
  tail -f "$LOG_FILE"
}

deploy_app() {
  echo "📦 Deploying $APP_NAME..."
  cd "$APP_DIR" || exit

  # Optional: Pull latest code
  if [ -d ".git" ]; then
    echo "⬇️ Pulling latest code..."
    git pull origin main || true
  fi

  echo "📦 Installing dependencies..."
  npm install --production

  # Optional: If you have React/Angular/Vue in client folder
  if [ -d "../client" ]; then
    echo "⚙️ Building frontend..."
    cd ../client && npm install && npm run build && cd "$APP_DIR"
  fi

  restart_app
}

case "$1" in
  start)
    start_app
    ;;
  stop)
    stop_app
    ;;
  restart)
    restart_app
    ;;
  status)
    status_app
    ;;
  logs)
    show_logs
    ;;
  deploy)
    deploy_app
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|logs|deploy}"
    exit 1
    ;;
esac
