# Usa un'immagine di base con Python 3.10
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# Imposta il maintainer
LABEL maintainer="Andrea"

# Imposta la directory di lavoro
WORKDIR /app

# Installa i pacchetti di sistema necessari
RUN apt update && apt install -y \
    python3.10 python3.10-venv python3.10-dev python3-pip \
    git wget curl unzip ffmpeg libgl1-mesa-glx \
    ninja-build build-essential \
    && apt clean


RUN ln -s /usr/local/cuda/include /usr/include/cuda \
    && ln -s /usr/local/cuda/lib64 /usr/lib/cuda

ENV CUDA_HOME=/usr/local/cuda
ENV CPLUS_INCLUDE_PATH=$CUDA_HOME/include
ENV LIBRARY_PATH=$CUDA_HOME/lib64
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# Crea un ambiente virtuale e attivalo
RUN python3 -m venv venv
ENV PATH="/app/venv/bin:$PATH"

# Installa pip e PyTorch prima per sfruttare la cache
RUN apt-get update && apt-get install -y ninja-build \
 && pip install --upgrade pip \
 && pip install wheel \
 && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 \
 && pip install --no-build-isolation diso

# Ora copia il resto del codice (non invalida il caching delle dipendenze)
COPY . /app

RUN pip install -e ".[tensorrt]" 
RUN pip install gradio



# Installa le dipendenze aggiuntive richieste
#RUN pip install gradio==4.0.2 sentencepiece

# Imposta le variabili di ambiente per CUDA e Torch
ENV CUDA_HOME=/usr/local/cuda
ENV PATH="$CUDA_HOME/bin:$PATH"
ENV LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"

# Imposta TORCH_CUDA_ARCH_LIST per evitare errori di compilazione
ENV TORCH_CUDA_ARCH_LIST="7.5;8.0;8.6;9.0"
ENV HF_HOME=/huggingface

# Verifica che NVCC sia disponibile
#RUN nvcc --version

#RUN pip install flash-attn --no-build-isolation

#RUN source patchtransformers.sh

# Espone la porta per Gradio
EXPOSE 8080

# Comando di default per avviare il server Gradio
CMD ["python3", "demo_gr.py", "--name", "flux-schnell","--device","cuda", "--share", "--port", "8080"]
#python demo_gr.py --name flux-schnell --device cuda --share --port 8080