---
name: run-python-in-nix
description: Run any Python on this NixOS machine inside an ephemeral nix shell with explicitly-named packages, never bare `python`/`pip`. Use whenever a Python script must be executed — interactively (REPL, one-liners) or not (running a .py file, a snippet, tests, a quick calculation) — and whenever installing/adding Python dependencies. Triggers on "run this python", "execute the script", "try it in python", "add numpy", etc.
---

# Run Python in a Nix Shell

This is a NixOS machine (flakes + `nix-command` enabled, nixpkgs `nixos-unstable`).
There is **no global mutable Python environment** and **`pip install` does not work**
the way it does on other distros. Always run Python through a Nix-provided
interpreter with the required packages declared explicitly.

## Core rule

Never invoke a bare `python`, `python3`, or `pip install`. Instead build an
interpreter that carries exactly the packages the script needs, then run it.

### One-off / scripts (preferred for ad-hoc work)

Use `nix shell` with `nixpkgs#python3.withPackages`, listing every package
explicitly:

```bash
nix shell --impure --expr 'with import <nixpkgs> {}; python3.withPackages (ps: with ps; [ numpy pandas requests ])' \
  --command python3 script.py
```

For a quick one-liner / REPL, swap the command:

```bash
nix shell --impure --expr 'with import <nixpkgs> {}; python3.withPackages (ps: with ps; [ numpy ])' \
  --command python3 -c 'import numpy; print(numpy.__version__)'
```

If the script genuinely needs **no third-party packages**, still go through Nix:

```bash
nix shell nixpkgs#python3 --command python3 script.py
```

### Project work with a `shell.nix`

If the working directory (or a parent) already has a `shell.nix` / `flake.nix`,
use it instead of an ad-hoc expr:

```bash
nix-shell --run 'python3 script.py'      # for shell.nix
nix develop --command python3 script.py  # for a flake devShell
```

When a project needs a reusable environment, create a `shell.nix` modeled on
`~/dropbox/dchb-climate/shell.nix` (it uses `python3.withPackages`, a GC-root
symlink to prevent garbage collection, and Jupyter kernel registration).

## Always

- **Name every package explicitly** in the `ps: with ps; [ ... ]` list. Do not
  rely on whatever happens to be on the system. If you discover a missing import
  while running, add that package to the list and re-run.
- Use Nix package names (e.g. `scikit-learn` → `scikit-learn`, `pyyaml` → `pyyaml`,
  `pillow` → `pillow`, `dateutil` → `python-dateutil`). If unsure of a name, the
  `mcp-nixos` MCP server is available to look packages up.
- Prefer `python3` (the system has no `python2`).

## Never

- `pip install ...` into the system or user site — it will fail or pollute state.
- Bare `python script.py` outside a nix shell.
- Assuming a package is present without listing it.
