#!/usr/bin/env python
"""Convert a PDF to Markdown with pymupdf4llm, with content-hash caching.

Usage: pdf_to_md.py <input.pdf> [output.md] [options]

Options:
  --docling / --accurate   (accepted for compatibility; falls back to pymupdf4llm)
  --no-progress            disable progress output
  --clear-cache            clear cache for this PDF and re-extract
  --clear-all-cache        clear entire cache directory and exit
  --cache-stats            show cache statistics and exit
"""
import datetime
import hashlib
import json
import shutil
import sys
from pathlib import Path

CACHE_ROOT = Path.home() / ".cache" / "pdf-to-markdown"
EXTRACTOR_VERSION = "1"


def cache_key(pdf: Path) -> str:
    st = pdf.stat()
    h = hashlib.sha256()
    h.update(str(pdf.resolve()).encode())
    h.update(f"{st.st_size}:{st.st_mtime_ns}:v{EXTRACTOR_VERSION}".encode())
    return h.hexdigest()[:16]


def extract(pdf: Path, cache_dir: Path, progress: bool) -> None:
    import pymupdf
    import pymupdf4llm

    images_dir = cache_dir / "images"
    images_dir.mkdir(parents=True, exist_ok=True)
    doc = pymupdf.open(pdf)
    total_pages = doc.page_count
    # pymupdf4llm's pure-Python drawing post-processing hangs on pages with
    # very large vector counts (dense scientific figures) and its
    # graphics_limit does not guard that path; fall back to plain text there.
    GRAPHICS_LIMIT = 5000
    heavy = {i for i, page in enumerate(doc) if len(page.get_bboxlog()) > GRAPHICS_LIMIT}
    if progress:
        print(f"Extracting {pdf.name} ({total_pages} pages)...", file=sys.stderr)
        if heavy:
            print(
                f"Plain-text fallback on {len(heavy)} graphics-heavy pages: "
                f"{sorted(i + 1 for i in heavy)}",
                file=sys.stderr,
            )
    parts = []
    for i in range(total_pages):
        if i in heavy:
            parts.append(
                f"\n**[Page {i+1}: graphics-heavy figure page; plain-text extraction]**\n\n"
                + doc[i].get_text()
            )
        else:
            parts.append(
                pymupdf4llm.to_markdown(
                    str(pdf),
                    pages=[i],
                    write_images=True,
                    image_path=str(images_dir),
                    show_progress=False,
                )
            )
        if progress:
            print(f"  page {i+1}/{total_pages}", file=sys.stderr)
    doc.close()
    md = "\n".join(parts)
    # rewrite absolute image paths to relative
    md = md.replace(str(images_dir) + "/", "images/")

    header = (
        "---\n"
        f"source: {pdf}\n"
        f"total_pages: {total_pages}\n"
        f"extracted_at: {datetime.datetime.now().isoformat(timespec='seconds')}\n"
        "images_dir: images\n"
        "---\n\n"
    )
    imgs = sorted(images_dir.iterdir()) if images_dir.exists() else []
    if imgs:
        rows = "\n".join(
            f"| {i+1} | {p.name} | {p.stat().st_size/1024:.1f}KB |"
            for i, p in enumerate(imgs)
        )
        md += f"\n\n---\n\n## Extracted Images\n\n| # | File | Size |\n|---|------|------|\n{rows}\n"
    (cache_dir / "full_output.md").write_text(header + md)
    (cache_dir / "metadata.json").write_text(
        json.dumps(
            {
                "source": str(pdf),
                "size": pdf.stat().st_size,
                "mtime_ns": pdf.stat().st_mtime_ns,
                "total_pages": total_pages,
            },
            indent=2,
        )
    )


def main() -> int:
    args = [a for a in sys.argv[1:]]
    flags = {a for a in args if a.startswith("--")}
    pos = [a for a in args if not a.startswith("--")]

    if "--clear-all-cache" in flags:
        shutil.rmtree(CACHE_ROOT, ignore_errors=True)
        print("Cache cleared.")
        return 0
    if "--cache-stats" in flags:
        entries = list(CACHE_ROOT.iterdir()) if CACHE_ROOT.exists() else []
        size = sum(f.stat().st_size for e in entries for f in e.rglob("*") if f.is_file())
        print(f"Cache: {len(entries)} PDFs, {size/1e6:.1f} MB at {CACHE_ROOT}")
        return 0
    if not pos:
        print(__doc__)
        return 1

    pdf = Path(pos[0]).expanduser().resolve()
    if not pdf.is_file():
        print(f"Not found: {pdf}", file=sys.stderr)
        return 1
    out_md = Path(pos[1]).expanduser().resolve() if len(pos) > 1 else pdf.with_suffix(".md")
    progress = "--no-progress" not in flags

    cache_dir = CACHE_ROOT / cache_key(pdf)
    if "--clear-cache" in flags:
        shutil.rmtree(cache_dir, ignore_errors=True)

    from_cache = (cache_dir / "full_output.md").is_file()
    if not from_cache:
        extract(pdf, cache_dir, progress)

    text = (cache_dir / "full_output.md").read_text()
    text = text.replace("---\n\n", f"from_cache: {str(from_cache).lower()}\n---\n\n", 1)
    out_md.write_text(text)
    src_images = cache_dir / "images"
    if src_images.exists() and any(src_images.iterdir()):
        dst = out_md.parent / "images"
        dst.mkdir(exist_ok=True)
        for f in src_images.iterdir():
            shutil.copy2(f, dst / f.name)
    print(f"Wrote {out_md} (from_cache={from_cache})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
