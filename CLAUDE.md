# Claude Code Guidelines for downline-redux

## Project Overview

Roblox game built with Rojo. Luau codebase synced from filesystem to Studio.

**Experience ID**: 9452966121
**Place ID**: 95040662459276

## Dev Tool Roles

### Source of Truth (Code)
- **Rojo** - Luau code lives in `src/`. Filesystem is canonical.
- **Lune** - Test pure logic outside Roblox. No runtime dependencies.
- **Selene** - Static analysis. Catches bugs at lint time.
- **StyLua** - Formatting. Consistency, not correctness.

### Source of Truth (World)
- **MCP (Roblox Studio)** - World building: parts, terrain, lighting, models, spatial layout. Things that aren't code.
- **Blender** - Asset creation. Meshes, models exported to Roblox.

### Pipeline
- **Wally** - Package dependencies.
- **rbxcloud** - Query place info (read-only). Cannot publish - use Studio for that.

## MCP Usage Rules

**DO use MCP for:**
- Placing parts, models, terrain
- Adjusting lighting, atmosphere
- Querying runtime state (PlaceId, etc.)
- World building tasks

**DO NOT use MCP for:**
- Running Luau code that should be in the codebase
- Temporary logic changes
- Anything that makes it unclear what's actually in `src/`

**Principle:** If it's behavior, it lives in Rojo-synced files. If it's world/spatial, it can live in Studio via MCP.

## Project Structure

```
src/
  ReplicatedFirst/ # Loading screens, early client init (runs first)
  client/          # Client-side scripts (StarterPlayerScripts)
  server/          # Server-side scripts (ServerScriptService)
  shared/          # Shared modules (ReplicatedStorage)
  ServerStorage/   # Server-only modules/assets
Packages/          # Wally dependencies (gitignored)
tests/             # Lune tests
.github/workflows/ # CI (selene, stylua, lune)
```

## Packages

Available via `require(game.ReplicatedStorage.Packages.X)`:
- **Promise** - Async without callback hell
- **Signal** - Custom events

## Versioning

Subsystems are versioned independently in `src/shared/Version.luau`. Bump version when making changes to a subsystem.

On publish, update `PUBLISH_LOG.yml` with:
- Roblox version number
- Commit message
- Subsystem versions
- Summary of changes

Pre-commit hook validates PUBLISH_LOG.yml syntax and required fields.

## Commands

```bash
# Development
rojo serve                        # Sync to Studio (preferred)

# Quality
selene src/                       # Lint
stylua src/                       # Format
stylua --check src/               # Check formatting
lune run tests/Version.spec.luau  # Run tests
```

## Publishing

1. Code syncs live to Studio via `rojo serve`
2. World building via MCP or Studio
3. Publish from Studio: **File → Publish to Roblox**
4. Update `PUBLISH_LOG.yml` with version number

This captures everything: code + world state (parts, terrain, lighting).

**Why not rbxcloud for publishing?** rbxcloud publishes a `.rbxl` file built from filesystem only. It does NOT capture world state (parts, terrain, lighting) created via MCP or Studio. Only Studio publish gets both code + world.
