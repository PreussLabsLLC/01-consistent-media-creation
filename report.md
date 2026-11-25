# Santa Worker: Local GPU Adaptation Report

**Date:** November 24, 2026\
**Project:** DataTalksClub --- Production AI Agents for Media Generation\
**Scope:** Module 01, containerized media generation on a local RTX 3090 instead of Nebius serverless GPUs.

## 1. Executive summary

The course's Santa worker was successfully adapted to generate illustrations and animated clips locally. The original Wan 2.2 A14B video model was impractical for the available hardware (an initial run displayed an estimated runtime of approximately ten hours; it was not completed). Replacing it with Wan 2.2 TI2V 5B and enabling model CPU offloading and VAE tiling produced good-quality five-second animations at 1024 × 576 in approximately six minutes, using native BF16 weights without quantization.

The most important optimization was avoiding simultaneous GPU residency of the entire video pipeline. At 832 × 480, the combined offloading and tiling changes reduced generation time from 695.9 to 256.2 seconds (2.72× speedup) and peak PyTorch reserved memory from 28.17 to 12.98 GiB (54% reduction).

## 2. Environment

-   Windows 11 workstation, NVIDIA GeForce RTX 3090 (24 GiB VRAM).
-   Docker Desktop with WSL2 / Ubuntu 24.04 backend.
-   Python 3.12, PyTorch 2.13.0+cu130, Diffusers 0.39.0.
-   TorchAO 0.18.0 installed experimentally; not required for the successful BF16 path.
-   Docker image: `santa-worker:local`; persistent development container: `santa-dev`.
-   Host data directory: `D:\SantaData` mounted at `/data`.
-   Host model cache: `D:\HuggingFace` mounted at `/cache/huggingface`.
-   Course source: [module 01 code](https://github.com/DataTalksClub/production-ai-agents-for-media-generation/tree/main/01-consistent-media-generation-on-serverless-gpus/code).

Example Windows CMD launch (for a new container):

``` cmd
docker run -dit --name santa-dev --gpus all --mount "type=bind,source=D:\SantaData,target=/data" --mount "type=bind,source=D:\HuggingFace,target=/cache/huggingface" --entrypoint /bin/bash santa-worker:local
docker exec -it santa-dev /bin/bash
```

## 3. Changes to the worker

### 3.1 `models.py`: replace the video model and tune parameters

Original model: `Wan-AI/Wan2.2-I2V-A14B-Diffusers` (dual-expert architecture).

Replacement: `Wan-AI/Wan2.2-TI2V-5B-Diffusers` (single transformer, text/image-to-video).

Recommended effective settings (adapt the existing `VideoSpec` definition and its `params` property; this is not a complete replacement class):

``` python
model="Wan-AI/Wan2.2-TI2V-5B-Diffusers"
width=1024
height=576
num_frames=81
num_inference_steps=40
guidance_scale=3.5
fps=16
```

Retain the existing seed for controlled comparisons. Verify effective parameters, because the source contained more than one frame-count entry:

``` bash
cd /app
python - <<'PY'
from models import WAN_I2V
print(WAN_I2V)
print(WAN_I2V.params)
PY
```

The 5B pipeline requires spatial dimensions divisible by 32; a requested 1280 × 720 was automatically adjusted to 1280 × 704. Frame counts of the form 4n+1 are appropriate for the model's temporal compression. At 16 fps, 81 frames produce 5.0625 seconds of video.

### 3.2 `batch_inference.py`: video model loader

The original loader returned `pipe.to("cuda")`, putting all pipeline components on the GPU together. Replace it with the following tested approach:

``` python
def load_video_model() -> WanImageToVideoPipeline:
    """Wan2.2 5B image-to-video with CPU offloading."""
    import torch
    from diffusers import WanImageToVideoPipeline

    pipe = WanImageToVideoPipeline.from_pretrained(
        WAN_I2V.model,
        torch_dtype=torch.bfloat16,
    )
    pipe.enable_model_cpu_offload()
    pipe.vae.enable_tiling()
    return pipe
```

Do not subsequently call `pipe.to("cuda")`. Model offloading allows the text encoder, transformer and VAE to use GPU memory at different stages. Tiling reduces VAE decoding memory pressure. Accelerate must be available (it was already working in the test container).

The downloaded model configuration already provided `expand_timesteps=True`, `boundary_ratio=None`, no second transformer, and a UniPC scheduler with `flow_shift=5.0`. No explicit scheduler override was needed. The successful loader did not explicitly load an FP32 VAE.

### 3.3 `batch_inference.py`: animation parameters

The A14B-specific `guidance_scale_2` caused a ValueError with the single-transformer model. Filter it out before calling the pipeline. Keep the existing image preparation and CUDA generator.

``` python
params = dict(WAN_I2V.params)
params.pop("guidance_scale_2", None)
params["negative_prompt"] = (
    "blurry, low quality, flickering, distortion, morphing, "
    "warped objects, abrupt scene changes, text, letters, "
    "watermarks, people, faces, large snowflakes, "
    "foreground snow, obscured present, snowstorm, "
    "blizzard, excessive particles"
)

torch.cuda.reset_peak_memory_stats()
print("Parameters:", params, flush=True)
print("Scheduler:", pipe.scheduler.config, flush=True)
print("Pipeline:", pipe.config, flush=True)

frames = pipe(
    image=first_frame,
    prompt=MOTION,
    **params,
    generator=generator,
).frames[0]

print(f"Peak VRAM allocated: {torch.cuda.max_memory_allocated() / 2**30:.2f} GiB")
print(f"Peak VRAM reserved: {torch.cuda.max_memory_reserved() / 2**30:.2f} GiB")
```

The negative prompt above corrects a string concatenation typo observed in the last successful run (`particleswatermarks` and a duplicate comma). The corrected version is recommended but has not been benchmarked separately.

### 3.4 Motion prompt

The original prompt requested gentle motion and slow camera drift. A more dynamic prompt improved movement but large swirling snowflakes obscured the present. The final recommended prompt restrains the snow and preserves the subject:

``` python
MOTION = (
    "An enchanting animated Christmas storybook illustration. "
    "The camera slowly moves toward the Christmas present, "
    "creating gentle depth and parallax. "
    "The present remains sharp, clearly visible and unchanged "
    "throughout the entire scene. "
    "Small delicate snowflakes drift in the background. "
    "Christmas lights twinkle and tree branches gently sway. "
    "Rich colors, crisp details, smooth cinematic motion. "
    "Preserve the original illustration style."
)
```

### 3.5 Other files and tools

-   No changes to `common.py` were required for this video adaptation. Its existing VAE dtype adjustment belongs to the image pipeline.
-   Install `ffmpeg` if `ffprobe` is missing: `apt-get update && apt-get install -y ffmpeg`.
-   Higher export quality (`quality=9`) and saving raw PNG frames were suggested diagnostics; their application was not confirmed.

## 4. Experimental results

All times below are measured clip-generation latency, excluding model loading, unless noted. All video runs use the 5B BF16 model and 16 fps. Memory figures are PyTorch allocator peaks in GiB, not direct measurements of physical VRAM residency.

  ----------------------------------------------------------------------------------------------------------------------------------------------
  Resolution         Frames    Steps Offload + tiling     Load (s)    Clip (s)   Allocated    Reserved Quality / notes
  ---------------- -------- -------- ------------------ ---------- ----------- ----------- ----------- -----------------------------------------
  640 × 352              17       10 No                       99.1        31.5         ---         --- Poor final frames

  640 × 352              17       10 No                       99.7        30.6       23.99       25.34 Repeat with instrumentation

  640 × 352              17       40 No                       94.2        56.7       23.99       25.34 Much better

  640 × 352              33       40 No                        ---        82.1       24.01       25.30 Quality still low

  640 × 352              33       40 No                      107.6        84.5       24.01       25.30 Intended 81 frames; ffprobe revealed 33

  640 × 352              81       40 No                       95.2       213.4       24.09       25.74 Verified 81 frames; quality needs work

  832 × 480              81       40 No                       95.6       695.9       26.26       28.17 Better quality, severe slowdown

  832 × 480              81       40 Yes                      37.4       256.2       12.39       12.98 Major optimization

  1280 × 704             81       40 Yes                      38.0       559.1       14.21       15.83 Good; foreground snow obscured present

  **1024 × 576**     **81**   **40** **Yes**              **37.9**   **358.9**   **12.99**   **14.06** **Very good; recommended baseline**
  ----------------------------------------------------------------------------------------------------------------------------------------------

### Controlled comparison at 832 × 480

  Metric               Original   Optimized     Improvement
  ----------------- ----------- ----------- ---------------
  Model loading          95.6 s      37.4 s   61% less time
  Denoising               215 s       153 s   29% less time
  Clip generation       695.9 s     256.2 s   63% less time
  Peak allocated      26.26 GiB   12.39 GiB       53% lower
  Peak reserved       28.17 GiB   12.98 GiB       54% lower

The original allocator peaks exceeded physical VRAM, suggesting driver-managed memory pressure or shared-memory use under Windows/WSL2. Actual spill was not independently measured. Offloading and tiling were enabled together, so their individual contributions were not isolated.

### Other pipeline stages

Earlier local runs measured Sana illustration generation at 5.3 seconds and card composition at 0.4 seconds. The initial Sana load took approximately 295 seconds. Speech generation and final assembly have not yet been validated in the adapted complete worker.

## 5. Reproduction and verification

Run only the video stage to reuse the existing illustration. The development container used a local `clip` shell script invoked with `bash clip`. Its equivalent Python invocation is:

``` bash
cd /app
python - <<'PY'
from pathlib import Path
from batch_inference import run, Step
run(n=1, out=Path('/data/run'), steps=[Step.CLIP])
PY
```

Inspect output and metrics:

``` bash
ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,nb_frames,r_frame_rate,duration \
  -of default=noprint_wrappers=1 \
  /data/run/cards/k01/clip.mp4
cat /data/run/metrics_batch.json
```

Expected baseline output: 1024 × 576, 81 frames, 16 fps, approximately 5.0625 seconds. The 81-frame count was verified on the earlier 640 × 352 run; verify the final output as well.

Monitor GPU from another Windows terminal with `nvidia-smi -l 2`. Windows Task Manager can additionally show shared GPU memory. Save reference clips and metrics before rerunning because the worker may overwrite them.

## 6. Issues encountered and lessons learned

-   The A14B model downloaded approximately 35.9 GB and was impractically slow in the initial configuration. Its displayed ten-hour estimate was not a completed benchmark.
-   The native 5B pipeline download was approximately 22.8 GB, including supporting components. Quantized transformer weights alone would not replace the entire pipeline.
-   TorchAO imported successfully but Diffusers warned it could not import TorchAO tensor objects. No quantized checkpoint was tested. The warning did not prevent BF16 inference.
-   `guidance_scale_2` is incompatible with the single-transformer configuration; removing it resolved the inference error.
-   Ten inference steps were insufficient for satisfactory quality. Forty improved quality without increasing peak memory in the controlled 17-frame test.
-   Low resolution was a major quality limitation. Higher resolution and a more restrained motion prompt improved subjective results; quality was not evaluated with a formal metric.
-   Checking effective parameters and actual encoded output is essential: one intended 81-frame experiment still produced 33 frames.
-   Small MP4 size relative to a PNG is not necessarily a quality problem because video uses inter-frame compression.
-   CPU offloading and VAE tiling were more immediately valuable than quantization on this hardware.

## 7. Recommended next steps

1.  Back up the working source files and reference clip outside the container. From Windows CMD:

    ``` cmd
    docker cp santa-dev:/app/models.py .
    docker cp santa-dev:/app/batch_inference.py .
    ```

2.  Integrate the tested source changes into the Docker build context and rebuild the image for reproducibility. Keep the Hugging Face cache and output bind mounts. Record dependency versions; TorchAO is optional for the BF16 baseline.

3.  Run the full Santa pipeline, including speech and final assembly, and verify duration, audio/video synchronization and output quality.

4.  Optionally test 30 inference steps at 1024 × 576 against the 40-step baseline using the same seed and prompts.

5.  Consider GGUF or INT8 only if additional throughput or memory savings are needed. Loader compatibility, quality and actual speed remain untested.

## 8. Conclusion

The RTX 3090 is a viable local alternative for this course's video generation workload when using the smaller Wan 2.2 5B model with appropriate memory management. The recommended baseline is a five-second, 1024 × 576 BF16 clip generated in 358.9 seconds with 14.06 GiB peak reserved memory. No cloud GPU or quantized video model was required for the successful local clip tests.

This report is reconstructed from the conversation and supplied logs, not a direct inspection of the final container filesystem. Code snippets document the tested approach and recommended cleanup; the complete final source diff and end-to-end pipeline remain to be verified.
