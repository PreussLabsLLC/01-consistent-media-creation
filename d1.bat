docker run -it `
    --gpus all `
    --mount "type=bind,source=D:\SantaData,target=/data" `
    --mount "type=bind,source=D:\HuggingFace,target=/cache/huggingface" `
    --entrypoint /bin/bash `
    santa-worker:local