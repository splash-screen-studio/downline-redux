# Claude Code Guidelines for downline-redux

## Project Overview

Roblox game built with Rojo. Luau codebase synced from filesystem to Studio.

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
- **rbxcloud** - Publish to Roblox.

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
  client/          # Client-side scripts (StarterPlayerScripts)
  server/          # Server-side scripts (ServerScriptService)
  shared/          # Shared modules (ReplicatedStorage)
tests/             # Lune tests
```

## Versioning

Subsystems are versioned independently in `src/shared/Version.luau`. Bump version when making changes to a subsystem.

On publish, update `PUBLISH_LOG.md` with:
- Roblox version number
- Commit message
- Subsystem versions
- Summary of changes

## Commands

```bash
# Development
rojo serve                        # Sync to Studio

# Quality
selene src/                       # Lint
stylua src/                       # Format
stylua --check src/               # Check formatting
lune run tests/Version.spec.luau  # Run tests

# Build & Publish
rojo build -o game.rbxl           # Build place file
source .env && rbxcloud experience publish \
  -f game.rbxl \
  -i "$ROBLOX_PLACE_ID" \
  -u "$ROBLOX_EXPERIENCE_ID" \
  -t published \
  -a "$ROBLOX_API_KEY"
```

## Environment Variables

Stored in `.env` (gitignored):
- `ROBLOX_EXPERIENCE_ID` - Universe ID
- `ROBLOX_PLACE_ID` - Place ID
- `ROBLOX_API_KEY` - Open Cloud API key
