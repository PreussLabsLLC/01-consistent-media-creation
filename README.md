## Completed Module 1 of Production AI Agents for Generative Media!

I used the provided Santa kids/wishlists to help Santa get going.

I tried to setup a media production pipeline locally running on my 
windows 11 workstation with Ubuntu 24.04 installed in docker/WSL.
It enjoys 128GB Ram, an intel core ultra 270k plus CPU, and a 24GB VRAM
Nvidia RTX 3090 GPU.

I used the dockerfile from 
https://github.com/DataTalksClub/production-ai-agents-for-media-generation/blob/main/01-consistent-media-generation-on-serverless-gpus/03-containers.md#the-fixed-dockerfile
to create a local docker container and ran the below to start it:

```
docker run -it `
    --gpus all `
    --mount "type=bind,source=D:\SantaData,target=/data" `
    --mount "type=bind,source=D:\HuggingFace,target=/cache/huggingface" `
    --entrypoint /bin/bash `
    santa-worker:local
```

I ran the smaller Wan 2.2 TI2V 5B on my local workstation and generated the first 10 cards (in the run folder).

```
06:27:15 10 kids from /assets/kids.csv, steps: text, illustration, card, clip, greeting, mix, out: /data/run/cards
06:28:51 clip model loaded in 32.9 s
06:34:28 clip 1/10 k01 357.6 s
06:39:10 clip 2/10 k02 297.9 s
06:43:49 clip 3/10 k03 294.4 s
06:48:24 clip 4/10 k04 292.9 s
06:53:00 clip 5/10 k05 292.2 s
06:57:38 clip 6/10 k06 291.8 s
07:02:14 clip 7/10 k07 292.2 s
07:06:50 clip 8/10 k08 292.4 s
07:11:27 clip 9/10 k09 291.8 s
07:16:03 clip 10/10 k10 291.8 s
```

It took about 50 minutes for the whole batch (including image, voice, video, and mixing) 
and about 300 seconds per video (median of 10).

At 1,000 assets, one item costs about $0.05 based on a cost of $1.00 per hour. 
This in turn is based on $500 per month for financing a $5,000 workstation 
utilized for 500 hours per month (FYI, there are 720 hours in most months).

- Question 1: Run the batch job locally to save the Nebius powder for more advanced work.
- Question 2: SANA,  Wan 2.2 TI2V 5B, Kokoro
- Question 3: Image, Video, Speech, Music
- Question 4: local batch job (docker container)
- Question 5: local RTX 3090 24GB VRAM
- Question 6: about 300 seconds per asset
- Question 7: about $0.05 per asset

My code (with lots of help from ChatGPT): 
- https://github.com/PreussLabsLLC/01-consistent-media-creation/blob/main/batch_inference.py
- https://github.com/PreussLabsLLC/01-consistent-media-creation/blob/main/report.md

@DataTalksClub @Nebius
