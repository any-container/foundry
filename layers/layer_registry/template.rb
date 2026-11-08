# Layer Registry injection. See rails/LAYER.md.
source_paths.unshift(File.expand_path("rails", __dir__))

# 1. Copy layers/ (manifest and description), config/layers.rb, the boot initializer, and the spec.
#    rails/LAYER.md is documentation, not payload.
#    Thor prompts on conflicts. An existing layers/0-manifest.yml is the host's deployment config:
#    keep it and add the missing entry below.
directory ".", ".", exclude_pattern: %r{/(layers/0-manifest\.yml|LAYER\.md)\z}

# 2. Create the manifest if absent, otherwise append the layer_registry entry once.
manifest = "layers/0-manifest.yml"
entry = %(LAYER_LAYER_REGISTRY: "true"\n)
if File.exist?(manifest)
  append_to_file manifest, entry unless File.read(manifest).include?("LAYER_LAYER_REGISTRY:")
else
  copy_file manifest, manifest
end
