# Loads features/0-manifest.yml into ENV, then checks it. See features/layer_registry.md.
require_relative "../features"

Features.load_env!
Features.validate!
