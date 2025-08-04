#!/bin/bash

echo "Stopping Kali Linux Docker Environment..."

cd "$(dirname "$0")/.."

docker-compose down

echo "[*] Kali Linux containers stopped."