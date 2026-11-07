---
type: Layer
title: Routing and Service Architecture
description: AGENTS.md routing and per-folder STANDARDS.md coding conventions.
tags: [feature]
layer: routing_and_service_architecture
generated: { by: process:claude-code, at: 2026-11-05T00:00:00Z }
status: stable
---

# Routing and Service Architecture

V2 of the routing and service architecture feature. Agentic routing for an application: an `AGENTS.md` at the app root tells agents to read the `STANDARDS.md` in each source folder before changing code there.

## Concepts
- `AGENTS.md` at the app root is the single routing file. It lists every `STANDARDS.md` and the rules that apply app-wide.
- Each source folder holds a `STANDARDS.md` with the conventions for code in that folder.
- Other agent tools read their own file names (`CLAUDE.md`, `GEMINI.md`, `CONVENTIONS.md` (Aider), `.cursorrules`, `.windsurfrules`, `.clinerules`, `.rules` (Zed), `.github/copilot-instructions.md`). Each is a symlink to `AGENTS.md`, so there is one source of truth. Existing files are left untouched.
- Injection is additive. It never deletes host code.

## Configuration
None.

## Interface
Documentation only. Agents read `AGENTS.md`, then the `STANDARDS.md` in the folder they are editing.

## Implementations
| Folder | Stack | Details |
|--------|-------|---------|
| `rails/` | Rails 8.1, RSpec, ROM, Jbuilder | [rails/LAYER.md](rails/LAYER.md) |
