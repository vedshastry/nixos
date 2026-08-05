#!/usr/bin/env python3
"""Strip assistant output from a chat-export markdown file, keeping only the user's prompts.

Usage:
    extract_prompts.py INPUT.md [-o OUTPUT.md] [--user-marker RE] [--assistant-marker RE]
                       [--no-frontmatter] [--title TITLE] [--source-url URL]

Default markers match the Gemini "# you asked" / "# gemini response" export shape and the common
"## User" / "## Assistant" (ChatGPT/Claude) shape. Everything between a user marker and the next
assistant marker is kept verbatim, including a `message time:` line if the export carries one.

Verbatim means verbatim: no reflowing, no spelling fixes, no cleanup of voice-typing artifacts.
"""

from __future__ import annotations

import argparse
import datetime as _dt
import re
import sys
from pathlib import Path

USER_MARKER = r"^#{1,6}\s*(you asked|user|prompt|me)\b.*$|^\*\*(You|User)\*\*:?\s*$"
ASSISTANT_MARKER = (
    r"^#{1,6}\s*(gemini|chatgpt|claude|assistant|model|response|answer)\b.*$"
    r"|^\*\*(Gemini|ChatGPT|Claude|Assistant)\*\*:?\s*$"
)

FRONTMATTER = """---
title: {title}
created: {created}
updated: {created}
scope: private
author: {author} (prompts verbatim)
register: verbatim — do not edit
status: primary source
governed_by: {governed_by}
---

# {title}

> My prompts only, extracted verbatim from `{source}`{url}. **All model output stripped.**
> Primary source: outranks anything synthesized from it.
"""


def extract(text: str, user_re: re.Pattern, asst_re: re.Pattern) -> list[str]:
    blocks: list[str] = []
    buf: list[str] | None = None
    for line in text.splitlines():
        if user_re.match(line):
            if buf is not None:
                blocks.append("\n".join(buf))
            buf = []
            continue
        if asst_re.match(line):
            if buf is not None:
                blocks.append("\n".join(buf))
            buf = None
            continue
        if buf is not None:
            buf.append(line)
    if buf is not None:
        blocks.append("\n".join(buf))

    out = []
    for b in blocks:
        # trim blank lines and the horizontal rules the exports leave behind, top and bottom
        b = re.sub(r"\A(\s*(-{3,}|\*{3,}|_{3,})?\s*\n)+", "", b)
        b = re.sub(r"(\n\s*(-{3,}|\*{3,}|_{3,})?\s*)+\Z", "", b)
        if b.strip():
            out.append(b)
    return out


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("input", type=Path)
    p.add_argument("-o", "--output", type=Path, help="default: <input stem>-you-asked-extract.md alongside the input")
    p.add_argument("--user-marker", default=USER_MARKER)
    p.add_argument("--assistant-marker", default=ASSISTANT_MARKER)
    p.add_argument("--no-frontmatter", action="store_true", help="emit bare prompt blocks only")
    p.add_argument("--title")
    p.add_argument("--author", default="Ved Shastry")
    p.add_argument("--governed-by", default="../../constitution-method.md")
    p.add_argument("--source-url", default="")
    p.add_argument("--created", default=None, help="YYYY-MM-DD for the frontmatter; default: file mtime")
    args = p.parse_args()

    text = args.input.read_text(encoding="utf-8")
    blocks = extract(
        text,
        re.compile(args.user_marker, re.IGNORECASE),
        re.compile(args.assistant_marker, re.IGNORECASE),
    )
    if not blocks:
        print(
            f"error: no prompts found in {args.input}. Inspect the file's own heading shape and pass\n"
            f"       --user-marker / --assistant-marker regexes that match it.",
            file=sys.stderr,
        )
        return 1

    out_path = args.output or args.input.with_name(args.input.stem + "-you-asked-extract.md")
    body = "\n\n---\n\n".join(blocks) + "\n"

    if args.no_frontmatter:
        out_path.write_text(body, encoding="utf-8")
    else:
        created = args.created or _dt.date.fromtimestamp(args.input.stat().st_mtime).isoformat()
        title = args.title or (args.input.stem.replace("-", " ").replace("_", " ") + ' — "you asked" extract')
        head = FRONTMATTER.format(
            title=title,
            created=created,
            author=args.author,
            governed_by=args.governed_by,
            source=args.input.name,
            url=f" ({args.source_url})" if args.source_url else "",
        )
        out_path.write_text(head + "\n" + body, encoding="utf-8")

    kept = sum(len(b) for b in blocks)
    print(f"{out_path}: {len(blocks)} prompts, {kept:,} chars kept of {len(text):,} ({kept / len(text):.0%})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
