---
always_on: true
depends_on: []
gems: []
---
# Layer Registry

Tracks which layers are built into this app and which are switched on in this deployment.

- `layers/<name>.md` describes one layer. The front matter lists `always_on`, `depends_on` (layer names), and `gems` (name and optional version).
- `layers/0-manifest.yml` maps each layer to its ENV variable, `LAYER_<NAME>`.
- `config/layers.rb` defines `Layers`.
- `config/initializers/00_layers.rb` loads the manifest into ENV and validates it at boot.

## Interface

    Layers.enabled?(:name)   # toggled on, and every dependency enabled
    Layers.built?(:name)     # a description file exists
    Layers.names             # every built layer
    Layers.gems              # gems of every built layer

An `always_on` layer is enabled whatever its ENV value. Boot fails if a layer is enabled while a dependency is off, a dependency is unknown or cyclic, or the manifest and the description files disagree.
