---
type: Layer
title: Layer Registry
description: Per-deployment toggles for injected layers, loaded into ENV at boot.
tags: [feature]
layer: layer_registry
generated: { by: process:claude-code, at: 2026-11-08T00:00:00Z }
status: stable
---

# Layer Registry

Tracks which layers are built into the app and which are switched on in this deployment. Layers are toggled per deployment through ENV variables; the static default for each lives in a manifest. Every other layer that is toggled depends on this one and must be injected after it.

## Concepts
- One description file per layer, with `always_on`, `depends_on` (layer names) and `gems` metadata.
- One manifest mapping each layer to an ENV variable, `FEATURE_<NAME>`, set to `"true"` or `"false"`.
- Real ENV overrides the manifest. An `always_on` layer is enabled whatever its ENV value.
- Boot validates the registry and fails if it is inconsistent (missing description or entry, unknown dependency, cycle, enabled layer with a disabled dependency).

## Configuration
Per deployment: `FEATURE_<NAME>` ENV variables.

## Interface

    Features.enabled?(:name)   # toggled on, and every dependency enabled
    Features.toggled?(:name)   # this layer's own switch only
    Features.built?(:name)     # a description file exists
    Features.names             # every built layer
    Features.gems              # gems of every built layer

## Implementations
| Folder | Stack | Details |
|--------|-------|---------|
| `rails/` | Rails 8.1, RSpec | [rails/LAYER.md](rails/LAYER.md) |
