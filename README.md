# R house style — drop-in kit

For a solo analysis lab. Author is an old C / Windows programmer.
This folder is the style kit, not the analysis.

## What to copy into a new project

Copy these to the **root** of the project:

- `AGENTS.md` — the style guide. Humans read it. Grok Build, Cursor, Codex,
  and most coding agents read it too. One file. Do not maintain a second
  constitution.
- `air.toml` — Posit Air formatter. Makes `<-`, 4-space indent, and 80-column
  wrapping automatic. Four-space indent is a house override of tidyverse's
  two-space default; Air is what stops an editor or agent from reverting it.
- `.lintr` — tells lintr the same 4-space rule so it does not fight Air.

Optional:

- `C-TO-R.md` — one-screen map of old habits. Keep next to `AGENTS.md` if you
  want the handshake visible. Agents should still follow `AGENTS.md`.

Do **not** use a legacy `.cursorrules` file. Cursor reads `AGENTS.md`.

## Recommended setup for a replication

1. New folder. In RStudio: *File → New Project → Existing Directory*
   (or New Directory → New Project).
2. Paste `AGENTS.md`, `air.toml`, and `.lintr` at the project root.
3. Copy the already-done script in as `00-original-reference.R`.
   Leave it alone. Do not restyle it. It is the spec.
4. Write the replica as `01-replicate-<short-name>.R`, or split into
   `01-load.R` / `02-clean.R` / `03-analyze.R` / `04-plot.R` if the original
   was long.
5. Set the editor tab width to 4 so it matches Air.
   RStudio: Tools → Global Options → Code → Editing → Tab width 4
   (insert spaces, not tabs). Cursor / Positron workspace:
   `"editor.tabSize": 4`, `"editor.insertSpaces": true`.
6. Install Air and turn on format-on-save
   ([Air editors guide](https://posit-dev.github.io/air/editors.html)).
   In Positron / VS Code / Cursor: command **Air: Initialize Workspace Folder**.
   In a terminal from the project root: `air format .`
7. Later, when the replica is honest: `usethis::use_git()` then
   `usethis::use_github()`. Still no PHI.

Write and run the R in RStudio (or Positron). Use Grok Build or Cursor
against the same folder when you want an agent. Point the agent at the
folder so it sees `AGENTS.md`. If a chat tool has not picked up the file,
paste `AGENTS.md` once at the start of the session.

## What this kit will not do

- It will not restyle the 1994 C / Raima port. Leave that tree alone.
- It will not turn the first project into a package. Flat scripts first.
- It will not put patient data on GitHub.
