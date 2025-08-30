#!/bin/bash
# Node.js App Deployment Management Script
# Save as: deploy.sh
# Usage: ./deploy.sh {start|stop|restart|status|logs}

APP_NAME="my-node-app"
APP_DIR="/var/www/app_pos/server"
APP_ENTRY="server.js"   # change this to your entry file (e.g., app.js, index.js)
NODE_ENV="production"
LOG_FILE="$APP_DIR/$APP_NAME.log"
PID_FILE="$APP_DIR/$APP_NAME.pid"

start_app() {
  if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "$APP_NAME is already running."
    exit 1
  fi
  echo "Starting $APP_NAME..."
  cd "$APP_DIR" || exit
  NODE_ENV=$NODE_ENV nohup node "$APP_ENTRY" > "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
  echo "$APP_NAME started with PID $(cat $PID_FILE)"
}

stop_app() {
  if [ ! -f "$PID_FILE" ] || ! kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "$APP_NAME is not running."
    exit 1
  fi
  echo "Stopping $APP_NAME..."
  kill -15 $(cat "$PID_FILE")
  rm -f "$PID_FILE"
  echo "$APP_NAME stopped."
}

restart_app() {
  echo "Restarting $APP_NAME..."
  stop_app
  start_app
}

status_app() {
  if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "$APP_NAME is running with PID $(cat $PID_FILE)"
  else
    echo "$APP_NAME is not running."
  fi
}

show_logs() {
  tail -f "$LOG_FILE"
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
  *)
    echo "Usage: $0 {start|stop|restart|status|logs}"
    exit 1
    ;;
esac
