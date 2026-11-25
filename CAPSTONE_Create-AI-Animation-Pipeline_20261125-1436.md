# you asked

message time: 2026-11-25 14:24:18

media generation with ai: how to create southpark style animations with consistent characters, episodes lasting about a minute, with llm generated storylines, background music, and speech and sound effects?

---

# chatgpt response

For one-minute animated comedy episodes with consistent characters, dialogue, background music and sound effects, I would build an **AI-powered miniature animation studio**, rather than rely entirely on generative video.

South Park is particularly suitable as inspiration because its simplified 2D cutout animation doesn't require photorealism, fluid body movements or complex facial expressions. Limited animation is part of the aesthetic, rather than a technical shortcoming.

Considering your existing media-generation environment with the RTX 3090 (24 GB), WSL, Python and local AI models, much of this could run locally and be automated.

## 1. The production pipeline

Each department could ultimately become a separate AI agent or deterministic Python module, with structured JSON passed between them.

## 2. The visual approach

**Cutout animation**

Simple shapes, flat colors, limited movements and reusable assets.

**Character sprite sheets**

Interchangeable mouths, eyes, expressions, limbs and poses.

**Reusable sets**

Living rooms, offices, streets, restaurants and other recurring locations.

**Storyboard-driven scenes**

Wide shots, close-ups, reaction shots and comic timing.

The key decision is to use AI to **generate the assets**, but conventional programmatic animation to bring them to life.

This solves the character consistency problem at its root. Rather than asking a video model to reinvent a character in every clip, you reuse exactly the same character assets across hundreds of episodes.

You could establish your own original characters and visual identity while retaining the low-budget cutout comedy aesthetic.

## 3. Recommended software stack

I would aim for a predominantly open-source, locally hosted production pipeline.

| Production task | Software / model | Hardware |
|--------|--------|--------|
| Story and dialogue | Qwen / GPT-OSS | Mac mini |
| Screenplay and directing | LLM with structured JSON | Mac mini |
| Character design | FLUX / Qwen-Image | RTX 3090 |
| Background generation | FLUX / Stable Diffusion XL | RTX 3090 |
| Character voices | Kokoro-82M / F5-TTS | RTX 3090 |
| Lip synchronization | Rhubarb Lip Sync | CPU |
| Cutout animation | Python, Pillow, Skia | CPU |
| Special video sequences | Wan 2.2 | RTX 3090 |
| Background music | ACE-Step / MusicGen | RTX 3090 |
| Sound effects | AudioLDM 2 | RTX 3090 |
| Audio mixing | FFmpeg / Pydub | CPU |
| Final rendering | FFmpeg / NVENC | RTX 3090 |

There are also some particularly relevant existing open-source projects worth investigating\:

- [Synctoon](https://github.com/Automate-Animation/synctoon) – LLM-directed cutout animation with facial expressions, gestures, lip-sync and backgrounds. Supports local Ollama endpoints.
- [AN](https://github.com/reeleehq/an) – Structured AI-driven animation in Python, including character rigs, gaze, blinking and mouth shapes.
- [Rhubarb Lip Sync](https://github.com/DanielSWolf/rhubarb-lip-sync) – Generates timed cartoon mouth movements from recorded speech.
- [PyToon](https://github.com/lukerbs/pytoon) – Programmatic cartoon animation driven by audio recordings.

Synctoon and AN are particularly close to the architecture I have in mind, although I haven't tested either of them.  [GitHub](https://github.com/Automate-Animation/synctoon?utm_source=chatgpt.com) [GitHub](https://github.com/reeleehq/an?utm_source=chatgpt.com) [GitHub](https://github.com/danielswolf/rhubarb-lip-sync?utm_source=chatgpt.com) [GitHub](https://github.com/lukerbs/pytoon?utm_source=chatgpt.com)

## 4. Creating consistent characters

Every character gets a permanent identity, voice, personality and collection of graphical assets.

For illustration, imagine a comedy series about three people running a dysfunctional technology startup.

**Walter — the engineer**

Sarcastic, technically competent, impatient.

Voice: mature, low-pitched, dry delivery

Signature expression: disapproving

---

**Kyle — the entrepreneur**

Enthusiastic, overconfident, addicted to AI buzzwords.

Voice: youthful, fast, energetic

Signature expression: exaggerated optimism

---

**Susan — the accountant**

Pragmatic, unimpressed, the only voice of reason.

Voice: calm, precise, deadpan

Signature expression: raised eyebrow

These are illustrative casting concepts rather than finalized character designs.

Each character would have a JSON definition describing their personality, relationships, voice parameters and available animations.

### The character rig

---

Interchangeable mouth shapes (visemes)

You would generate these assets once, then use a small library of animation primitives\:

`idle`, `talk`, `blink`, `walk`, `nod`, `shake_head`, `shrug`, `point`, `angry`, `laugh`, `facepalm`, `eye_roll`\.

Combining those primitives would cover a surprisingly large percentage of animated comedy.

## 5. Fully automated episode production

The LLM should act as a screenwriter and director, producing a screenplay that is both human-readable and machine-executable.

For example, the user supplies a single premise\:

*Walter discovers that their new \$5,000 AI workstation is being used exclusively to generate cat pictures.*

The LLM generates an episode called **Return on Investment**\.

**Return on Investment**

Episode 001 · 60 seconds

The director converts that screenplay into a structured format such as\:

```json
{
  "scene": 3,
  "duration": 6.5,
  "background": "startup_office",
  "camera": "medium_closeup",
  "characters": [
    {
      "id": "walter",
      "position": [0.3, 0.8],
      "expression": "annoyed",
      "action": "point"
    },
    {
      "id": "kyle",
      "position": [0.7, 0.8],
      "expression": "proud"
    }
  ],
  "dialogue": [
    {
      "speaker": "walter",
      "text": "Five thousand dollars. For cats?",
      "emotion": "incredulous",
      "start": 0.5
    }
  ],
  "sound_effects": [
    {
      "asset": "computer_fan",
      "start": 0,
      "volume": 0.2
    }
  ]
}
```

The renderer doesn't need to understand the joke. It simply executes the instructions.

Actual scene durations should be finalized after speech synthesis, not guessed exclusively by the LLM.

## 6. Speech, music and sound effects

**Speech — Kokoro or F5-TTS**

Kokoro is a good lightweight starting point. F5-TTS offers reference-audio-based voice generation for more distinctive recurring characters. Use original or authorized reference voices.

---

**Lip-sync — Rhubarb**

Analyze each generated dialogue WAV file and produce a timed sequence of mouth shapes. Only the speaking character's mouth needs to move.

---

**Music — ACE-Step**

Generate a permanent opening theme, closing theme, incidental music and short comedic musical stings. Reuse them throughout the series.

---

**Sound effects — AudioLDM 2**

Generate or acquire reusable sounds: doors, footsteps, explosions, computer noises, telephone rings and ambient backgrounds.

The audio mixer would maintain four independent tracks.

Example episode audio timeline

Automatically reduce music volume during dialogue and accentuate punchlines with sound effects.

## 7. Why not use Wan for the entire episode?

Your recent Wan clip-generation experiments averaged approximately five minutes per 81-frame clip.

Assuming 16 FPS, that translates into roughly an hour of GPU processing for a one-minute episode, before retries, editing and correcting character inconsistencies.

| Feature | Generative video | Programmatic cutout |
|--------|--------|--------|
| Character consistency | Variable | Exact |
| Lip-sync | Challenging | Deterministic |
| Multiple characters | Challenging | Straightforward |
| Repeatable scenes | Difficult | Exact |
| Editing individual actions | Difficult | Easy |
| Rendering time | Relatively high | Relatively low |
| GPU requirements | High | Low |
| Creative motion | Excellent potential | Limited to available animations |
| Automated series production | Complex | Well suited |

A hybrid approach gives you the best of both worlds. Use Wan for occasional dream sequences, dramatic flashbacks, explosions or other special scenes while keeping the regular cast in deterministic animation.

## 8. Estimated production time per episode

Once the character and asset library exists, I would aim for the following initial performance targets on your existing machines.

# 3–8 minutes

Target automated production time for a 60-second episode

Engineering estimates, not measured benchmarks. Assumes reusable art, music and sound effects, with no diffusion video generation.

The art library is the significant upfront investment. Subsequent episodes should be computationally inexpensive.

## 9. Proposed project structure

This would make an excellent companion project to your consistent media creation work.

```text
ai-cartoon-studio/
├── bible/
│   ├── universe.md
│   ├── characters.json
│   ├── writing_style.md
│   └── continuity.json
├── assets/
│   ├── characters/
│   ├── backgrounds/
│   ├── props/
│   ├── voices/
│   ├── music/
│   └── sfx/
├── agents/
│   ├── writer.py
│   ├── director.py
│   └── continuity.py
├── engine/
│   ├── speech.py
│   ├── lipsync.py
│   ├── animation.py
│   ├── compositor.py
│   └── audio.py
├── episodes/
│   └── e001/
│       ├── premise.txt
│       ├── screenplay.json
│       ├── timeline.json
│       ├── audio/
│       └── episode.mp4
└── produce.py
```

Eventually, the entire production could be triggered with\:

```bash
uv run python produce.py \
  --premise "The AI intern accidentally becomes CEO" \
  --duration 60 \
  --episode 002
```

The series bible would even allow the LLM to maintain continuity across episodes, develop running gags, remember previous events and evolve character relationships.

## 10. Implementation roadmap

| Phase | Deliverable |
|--------|--------|
| 1 | One character speaking with synchronized mouth movements |
| 2 | Two characters having a conversation in a fixed setting |
| 3 | Expressions, gestures, camera cuts and reaction shots |
| 4 | LLM-generated screenplay and automated directing |
| 5 | Music, sound effects and audio mixing |
| 6 | Fully automated one-minute episodes |
| 7 | Persistent series continuity and occasional generative video |

For the initial prototype, I would deliberately avoid diffusion models altogether. Two simple characters, one office background, Kokoro, Rhubarb, Pillow and FFmpeg are sufficient to demonstrate the entire concept.

Once that works, we can introduce more sophisticated AI-generated artwork and animation.

**The particularly attractive aspect of this project is that it combines generative AI with traditional software engineering.** Instead of trying to generate an entire movie with one enormous model, we build a virtual animation studio whose individual components are replaceable, testable and independently improvable.

And your existing Mac mini and RTX 3090 workstation should make a very capable two-machine production studio without requiring another hardware investment.

![Южный парк фон - Zefirka.club фото и картинки](https://images.openai.com/static-rsc-4/gtCqPX2gP_uBpDBxTkAC_VmBdlHmZNG21t00v23hRXhB3kP9FQFr1CbiKa8ybr9T72jorHQhhfQS1YMDyMcSoUtNXfUP9SfIs6WfyEWHo8TXZBgVT7ETFOYZ_wztsfcHmqWPduF4qERaYQoH4W9rwyyiJeuDW-_auWrlvFHHqKCuDnEzf_b8u2yF-kzzzzrp?purpose=fullsize)

![Stylized Cartoon Black Man Character Face Creation, with expressions, Lip-sync, Hand Gestures and emotions. Ideal for Animations, Presentations and posing, Flat Design, Vector Illustration](https://images.openai.com/static-rsc-4/xCjlFtzlGkW9d4jAZDyix6AGgp-RUnAz-an9MONrfeST8kM8-GD9cuO0H3HMCW1AayZAe5OKcQJtkG-fWWztNVCjWEjZxwNSq97j7K6Z1ZR_daG7xe92prWqJSCIfCVCwLGVFaoQFBaJg7Bf7SOwoU1_0GdZUZKcLP2b_-fsH7FVarp9i9Pdl4F34yQppiNQ?purpose=fullsize)

![Animation Backgrounds - House (10) | Images :: Behance](https://images.openai.com/static-rsc-4/aGJHhRN161r3b31IFsf7zsPCuuPKvo9kjTtUUcHAtUe5-pq7-bQXONuR2Nk2mECbmjlHR5-yR1VH1kNFDQIXjeeGUo_qOYvYaCrSKCSDKuKw0HMuxm6ro_xuph-xzow8lis8GZxk8VIpWyR2vKWfFVzf8swQ_e86ofve72ub4GtEts18Lt0XzRVEkqfqAgzf?purpose=fullsize)

![Hannah Shigeta Storyboard Portfolio: Rick and Morty Storyboard/ Character Design/ Layout](https://images.openai.com/static-rsc-4/gGuBPi8lkkCnIPZWJFRrWw2vOLsagi5nqXj7GF_c5rzqaSFiMrv-16jFzUKBjrHnSeCNZNjHOPyrYk_8IkSwAb3rA53p7zBU1qOjlz8FUS78uL4t2J9p_S9SIle8FTSNNpHuV_tYNM8E7lUbtRvCg5DWl3URQv_-UGsYuX-TCPjxA4qE56pgBAhhL5D60ZgR?purpose=fullsize)

![Cartoon vector flat man](https://images.openai.com/static-rsc-4/RwqcBKU8msfsw4fNYI8VKxPAMxe6vdWmcaeDtLl_ww4-En1C4W97I_2fUjoCawQyQxj9ymrzzkGVXvnszQ6j8MHh7wep0H2kD8uP7OZg7_G0PEmGzxlRwvGmGh95QuFotutJDjox1VLIfWqiJoLmmnSNYN9oUGdtrSjazbPO-cYNYu9XZVNRNMLDmRmr0PEw?purpose=fullsize)

![Diseño de personajes ( Frailejón Hernesto Perez ) :: Behance](https://images.openai.com/static-rsc-4/8amCFWPcTJoF3zIQ1nRlmmp5YY3ELnHNxmpPmI-fcnUjwTNNSGF8fEbWOkjfD-KD2eKyHGeJF52ksD-3EnYh9gLkpnx8sUdGoG60Us7OSOXFMBNat3ZFFZ1FwnRicmP0T9cPJzsfTjGVhezp_lEpjQONTpWy9hcQI8Qad_mi0pd6SoDf0B2o9y0r1nFJTT7O?purpose=fullsize)

![Cartoon funny girl sits leg on foot and arms crossed on chest. The displeased face of the character says that is annoy of something](https://images.openai.com/static-rsc-4/DW14zg2zuIeyNBgTpVMDd3Fa12j7PSKSVzUY_XyaMHX7O85mw7B2SaruRxGLvuXCjCdtyKOJ7LBsJ0kRIJh2VunIbZKaATjJ5XYE-upMbb1kxBkvwT_KH3N8TiCktSR66aDZo7lZlaA2jgip7sH1_CUe1APAcTSAQsjhBN9FbXsFvdRg4vKh9Koo3UACuHk7?purpose=fullsize)

![Kokoro-82M ONNX Runtime Inference Gradio Demo | kokoro-onnx](https://images.openai.com/static-rsc-4/Fn8NsQeeZr8wVcv8SnkkIunEOSeg5Z8mxJVjvHTLypPYeQEHhEVQvJHC3mKQdy8imD0CvY1-Tbyn2GXRv4hj_iWjmwVsCQrg_fV4uL-B0S2uW0Q8eRSIhvBKXHAKQin1nuSDbyd4kwj4ZzfQAJkGUwcTSQgkCLucJwAqtCVzzukEquSFuYb_gvdFdkbHEim6?purpose=fullsize)

![Cartoon Mouth Animation Lip Sync – Royalty-Free Vector | VectorStock](https://images.openai.com/static-rsc-4/OAYIl8enRu4blC_umZ3GV87gc2F2Tin9ehc2wH5PTSELJh24zxhXdXR1CGeZEUbdf1L_E-7WCQZdg9qHxyzeNc_-TsBuxylBfbiYPh5hvygjsTAK_RDxOppWswaZs0zPjZrHYiRW1DM3lzjs6sI1YjTGm19XoGcP4mNjPhdlMhDPLp0mH4JrqwwMEZl6-Bdw?purpose=fullsize)

![Generate AI Music with ACE-Step 1.5 | DigitalOcean](https://images.openai.com/static-rsc-4/_LXx_w2aD47J1harPRer74nnnbon-xxMMYdbyDZNR7uBB1CrjROlnedD-H_VMhNh_5EfpQ1GRDQXxH8Lc8eG59k84XQXtfAMIVUo5WNhyO-33m9vcTtO4MwZ8umCX9rAT0GbIzffALQYZ4q7yPl_4MjBJDnJfGkka5Y1hNPsRtGc42kEKYETpGOlriGPkBPF?purpose=fullsize)

![Top Game Audio Tools | Luciq](https://images.openai.com/static-rsc-4/desReFf09GlSalJJBJlU-zCC-id90SvvkRlcInRiynssWCM0aBU9p_HvxdJ-2gDc8Mkj4oYqFsjBcas2TRHBIbnKMJiOtURcv6VADuEsFNs-EJwUeBa2hTJMlanlU8XK2R4lU6pJ1OnXLQx0ZRij2kYNfJQWwuZirTjWtFTCjADsqv5ynKcQlRxK0lymrH1j?purpose=fullsize)

---

# you asked

message time: 2026-11-25 14:26:57

save that proposal as capstone.md

---

# chatgpt response

Saved the proposal as **[capstone.md](sandbox:/mnt/data/capstone.md)**, ready to add to your GitHub repository.

It includes all ten sections\:

- Production pipeline and architecture
- Recommended AI models and software stack
- Consistent character design and animation rigs
- Example episode and JSON scene specification
- Speech, lip-sync, music and sound effects
- Generative video versus programmatic animation
- Estimated production times
- Project directory structure
- Automated episode generation
- Seven-phase implementation roadmap

The visual diagrams have been converted into Markdown descriptions and tables, making the document suitable for GitHub and for use as a project specification with Codex.

📦 **Files delivered** · 2026-11-25 14:27
- 📎 **capstone.md** · MD

---
Powered by [AI Exporter](https://saveai.net)
