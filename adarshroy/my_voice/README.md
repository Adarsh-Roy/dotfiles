# my_voice

Turns a text file into speech in my own voice, fully offline on an Apple Silicon Mac.

```
my_voice script.txt        # writes script.wav next to script.txt (voice version 2)
my_voice -v1 script.txt    # same, using voice version 1
```

Paths can be relative to the current folder or absolute. It takes about 1.5 minutes
per minute of speech on an M3 Pro (18 GB). `my_voice` is an alias in `~/.zshrc`.

Emotion tags like `[laughter]` or `[sigh]` are accepted but currently sound like breathy
pauses, so plain text with normal punctuation works best.

Claude sessions use this through the `my-voice` skill (`.claude/skills/my-voice/SKILL.md` here,
linked from `~/.claude/skills/my-voice`). The skill covers how to write text that speaks well
and how to check the result.

## What lives where

Only this README and the `my_voice` script are in the public dotfiles repo. The rest
stays out of git on purpose:

| Path | What it is | Where it comes from |
|---|---|---|
| `my_voice` | the command | dotfiles (chezmoi) |
| `models/voice_v1/`, `models/voice_v2/` | my trained voice models (1.2 GB each, 16-bit) | private Hugging Face repo |
| `models/audio_tokenizer/` | stock audio converter, shared by both versions (0.8 GB) | private Hugging Face repo |
| `ref/me_ref.wav` | 10 s clip of my voice that sets tone and recording style | private Hugging Face repo |
| `.venv/` | Python environment | rebuilt with the commands below |

The models and the clip are private because anyone who has them can generate
speech that sounds like me.

## Setting it up on a new Mac

1. Apply the dotfiles (`chezmoi apply`). That brings this README, the script, and the alias.
2. Install [uv](https://docs.astral.sh/uv/) and build the Python environment:
   ```
   cd ~/adarshroy/my_voice
   uv venv -p 3.11 .venv
   uv pip install -p .venv torch==2.8.0 torchaudio==2.8.0 soundfile \
     "omnivoice @ git+https://github.com/k2-fsa/OmniVoice@08be0b4ccbac3e13e374e86fbfead4b4cac343e2"
   ```
3. Log in to Hugging Face and download the private model files into this folder:
   ```
   .venv/bin/hf auth login
   .venv/bin/hf download adxrsh/my-voice --local-dir ~/adarshroy/my_voice
   ```
   The two model folders link to the shared `models/audio_tokenizer` through
   `models/voice_v*/audio_tokenizer -> ../audio_tokenizer`. Recreate those links if a
   download turns them into plain folders.
4. Test: `echo "Hello from my new Mac." > /tmp/t.txt && my_voice /tmp/t.txt`

## How the voice was made

- **Base model:** [OmniVoice](https://github.com/k2-fsa/OmniVoice) (k2-fsa, 0.6B), the same
  engine the Voice Studio app uses. On its own, it copies a voice from a short clip.
- **Training:** a LoRA fine-tune (a small add-on trained on top of the frozen base model) on about
  42 minutes of my YouTube audio (@PengVim videos and shorts).
  - **v1:** 263 clips cut at Whisper's segment edges, mostly without punctuation; checkpoint 100 of 300.
  - **v2:** 359 clips re-cut at natural pauses and transcribed one by one, so most have
    proper punctuation. 18 clips were held out as a test set and never trained on. I kept
    checkpoint 400 of 400, which scored best on a fixed, repeated test.
- Each version is the add-on merged into the base model, then saved at 16-bit (generation
  already runs at 16-bit, so quality is unchanged).
- The training scripts and data live in `~/adarshroy/voice_cloning_exp` (not in git).
