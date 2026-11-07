---
name: my-voice
description: Use when personal work under ~/adarshroy needs speech in Adarsh's own voice - voiceover or narration for a PengVim YouTube video or Short, a tutorial, or any script he wants read aloud as a WAV file. Not for Dragonfruit work.
---

# my-voice

## Overview
`my_voice` turns a text file into a WAV file in Adarsh's trained voice. It runs fully offline on
his Mac. The model and command live in `~/adarshroy/my_voice` (setup: `README.md` there).

## Quick reference

| Need | Command |
|---|---|
| Speech for a script | `~/adarshroy/my_voice/my_voice path/to/script.txt` → writes `path/to/script.wav` |
| Use voice version 1 | `~/adarshroy/my_voice/my_voice -v1 path/to/script.txt` |

- Use the full path in tool calls. `my_voice` is only an alias in interactive zsh.
- It prints `wrote <file> (<seconds>s of audio, voice v2, took <seconds>s)`. Read the audio length from that line.
- It takes about 1.5 minutes per minute of speech, plus about 15 s to load the model. Run one at a time,
  because two at once compete for the GPU and memory on an 18 GB Mac.
- It overwrites an existing `.wav` with the same name.

## Writing text that speaks well
The model reads the text literally, so write it the way Adarsh would say it:
- Keys and symbols as words: `leader O B C`, `control E`, `dollar question mark`, `option N`.
- Normal punctuation sets the pauses: a full stop gives a pause and a falling tone, a comma a short break,
  a question mark rising.
- No markdown, no stage directions, no `[laughter]`/`[sigh]` tags. The tags come out as breathy pauses.
- One scene per file when the visuals must line up with the speech. Each scene WAV then gives that
  scene's exact duration. Join the WAVs afterwards (`ffmpeg -f concat`).

## Checking the result
Transcribe the WAV and compare it with the script:
```
~/adarshroy/my_voice/.venv/bin/python -c "import sys,torch; from transformers import pipeline; p=pipeline('automatic-speech-recognition','openai/whisper-large-v3-turbo',device='mps',dtype=torch.float32); print(p(sys.argv[1],generate_kwargs={'language':'en'})['text'])" file.wav
```
Tool names are the words most likely to come out wrong. Whisper's spelling is not the pronunciation.
"present term" for presenterm is the right sound, spelled oddly. Only respell when the *sound* is
wrong, and ask Adarsh how a name is said when you're unsure, instead of guessing from the transcript.
Respell in the text file and regenerate:

| Write | Not | Why |
|---|---|---|
| `presen-term` | `presenterm` | Adarsh says "presen-term". Don't end a sentence on it: there the voice clips it to "presenter". "presenter M" is wrong |
| `wez term` | `WezTerm` | |
| `cat-poo-chin` | `catppuccin` | |
| `tokyo night` | `tokyonight` | |

Keep the real spelling in captions: the caption text comes from the script, not from the voice file.

## Common mistakes
- Calling the bare alias `my_voice` from a non-interactive shell gives "command not found". Use the full path.
- Feeding a markdown script with headings or bullets makes it read the symbols aloud.
- Using it for anyone other than Adarsh, or for content he didn't approve. The voice is his.
