# Loads layers/0-manifest.yml into ENV, then checks it. See layers/layer_registry.md.
require_relative "../layers"

Layers.load_env!
Layers.validate!
