---
name: extract-prompts
description: Strip assistant/model output from an exported chat log (Gemini, ChatGPT, Claude) so only the user's own prompts remain, as a verbatim primary source. Use when the user says "keep only what I prompted", "strip the Gemini output", "you asked extract", or points at a conversation dump in ~/Dropbox/brain/raw/ that should become a context dump of their own words.
---

# Extract prompts from a chat export

Turns a full conversation dump into a **prompts-only primary source**. The model's output is noise for
this purpose; the user's own words — including voice-typing artifacts — are the signal.

## Run it

```bash
python3 ~/.claude/skills/extract-prompts/scripts/extract_prompts.py \
  "~/Dropbox/brain/raw/gemini/Some-Thread.md"
```

Writes `Some-Thread-you-asked-extract.md` next to the input and prints how many prompts were kept.
No dependencies beyond python3 — no nix shell needed for this one.

Useful flags:

- `-o PATH` — explicit output path.
- `--title "…"` — frontmatter/H1 title. Default is derived from the filename and is usually worth
  overriding with something that names the *thought*, not the export.
- `--source-url URL` — the chat URL, if the export's first line carries one.
- `--created YYYY-MM-DD` — defaults to the input's mtime; set it to the date of the **first** message
  in the thread, which is what `created` means in this corpus.
- `--governed-by ../../constitution-method.md` — adjust the relative depth for where the output lands.
- `--no-frontmatter` — bare blocks, no header.
- `--user-marker` / `--assistant-marker` — regexes, if the export uses a shape the defaults miss.

## Formats it already knows

| Export | User marker | Assistant marker |
|---|---|---|
| Gemini | `# you asked` | `# gemini response` |
| ChatGPT / Claude | `## User`, `**You**:` | `## Assistant`, `**ChatGPT**:` |

Anything else: open the file, find the two repeating headings, pass them as regexes. **Always check
the printed prompt count against `grep -c` on the user marker in the source** — a silent mismatch
means the markers are wrong and prompts were dropped.

## Rules that matter more than the script

1. **Verbatim, always.** Do not fix spelling, punctuation, or the artifacts of voice typing
   ("gene de say quoi", "Marla street"). The roughness is evidence of where and how it was said. The
   output is `register: verbatim — do not edit`, `status: primary source`.
2. **Never modify the original dump.** The extract is a new file alongside it; both stay.
3. **Extract ≠ synthesis.** The extract is raw material. Any reading of it goes in a *separate* file
   outside `raw/`, which links back to the extract. Per `constitution-method.md`, a synthesis must
   cite the extract, never another synthesis.
4. **Frontmatter follows the corpus spec** in `~/Dropbox/brain/CLAUDE.md`: nine fields, `created` is
   the date of the first message in the thread and never changes, `scope: private` by default.
5. **Say what was dropped.** Report the prompt count and the share of the file kept, so a later reader
   knows the extract is partial by construction.

## After extracting

Read the extract in full and tell the user what is actually in it — the recurring claim, the
observation they made twice without noticing, the question they asked at the end. That is the reason
they wanted the model output gone. Then offer where the synthesis should live (an existing life note,
or a new one), and cross-link both ways.
