# Project Rules

> **Version**: V1.9 | **Updated**: 2026-03-26 | **Owner**: Justin JU

## Purpose

This file stores long-term collaboration requirements for this project so they
do not need to be repeated in every session.

## Standing Rules

1. Before continuing work, read `CURRENT_STATE.md` for the current baseline.
2. Use `PHASE_HISTORY.md` for phase-organized history and `PROGRESS.md` for
   chronological detail.
3. Keep document responsibilities clear:
   - `CURRENT_STATE.md` is for current truth
   - `PHASE_HISTORY.md` is for staged history
   - `PROGRESS.md` is for dated log entries
   - `SUMMARY.md` is for delivery-level summary and latest document package notes

## Mandatory Rule For GitHub Docs Pushes

Every time documentation is pushed to GitHub, the document package must be
updated in the same batch.

Required actions:

1. Pick the next linear document version, for example `V1.9 -> V2.0`.
2. Update the version header in all core documentation files.
3. Update the `Updated` date in the same files.
4. Add a short "what was pushed" note to `SUMMARY.md`.
5. Make sure the push note describes the document scope clearly.

## Core Document Set

The version-unified core document set is:

- `SUMMARY.md`
- `CURRENT_STATE.md`
- `PHASE_HISTORY.md`
- `PROGRESS.md`
- `PROJECT_INDEX.md`
- `PROJECT_RULES.md`
- `QUICKSTART.md`
- `E203_FORMAL_INTEGRATION.md`
- `PHASE4_RECOVERY.md`
- `PHASE5_BOARD_PREP.md`
- `VIVADO_FPGA_HANDOFF.md`
- `SPEECH.md`

## Push Note Template

When a docs push is prepared, add a note to `SUMMARY.md` using this shape:

```text
Date: YYYY-MM-DD
Version: VX.Y
What was pushed:
- item 1
- item 2
- item 3
Affected docs:
- file 1
- file 2
```

## User Requirement Log

Append future standing requirements here instead of repeating them in chat.

### Active user requirements

1. Every GitHub docs push must update the unified document version.
2. Every GitHub docs push must state clearly what was pushed.

## Execution Checklist

Before a docs push:

1. Update the unified version number.
2. Update the `Updated` date.
3. Refresh `SUMMARY.md` with the push note.
4. Confirm new or moved documents are reflected in `PROJECT_INDEX.md`.
5. Confirm `CURRENT_STATE.md` still reflects the current truth.

After a docs push:

1. Add a dated entry to `PROGRESS.md` if the documentation package represents a
   real milestone.
2. Keep future user rules appended in this file.
