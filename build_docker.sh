#!/bin/bash
docker build -t flux .
echo "✅ Build completata!"
echo "👉 Per eseguire il container usa:"
echo "docker run --rm -it --gpus all -p 8083:8080 flux"
