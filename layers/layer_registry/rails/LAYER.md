# Layer Registry: Rails

Tracks which layers are built into the app and which are switched on in this deployment. Layers are toggled per deployment through ENV variables; the static default for each lives in `layers/0-manifest.yml`.

## Requirements
- Rails: 8.1
- Database: none
- Gems: none

## Injection
Run from the host app root:

    bin/rails app:template LOCATION=/path/to/layers/layer_registry/template.rb

The template:
- Copies `layers/layer_registry.md` (this layer's description) into the app's root `layers/` folder.
- Creates `layers/0-manifest.yml`. If the host already has one, it is kept and `LAYER_LAYER_REGISTRY: "true"` is appended once.
- Copies `config/layers.rb` (the `Layers` module) and `config/initializers/00_layers.rb`.
- Copies `spec/layer_registry/layers_spec.rb`.
- Makes no gem or route edits. Runs no migrations.

## Configuration
The app's `layers/` folder holds:

| File | Contents |
|------|----------|
| `0-manifest.yml` | Flat map of `LAYER_<NAME>` to `"true"` or `"false"`. The static representation of the layer ENV variables. |
| `<name>.md` | One description per layer. Front matter keys: `always_on` (default false), `depends_on` (layer names), `gems` (a name, or `name` and `version`). The body is free text. |

At boot the initializer copies each manifest entry into `ENV` unless the deployment already sets that variable, so real ENV overrides the manifest. It then validates:
- every description has a manifest entry, and every manifest entry has a description;
- every dependency exists, with no cycles;
- no enabled layer has a dependency switched off.

Any failure raises `Layers::Invalid` and stops boot.

An `always_on` layer is enabled whatever its ENV value.

## Interface

    Layers.enabled?(:name)   # toggled on, and every dependency enabled
    Layers.toggled?(:name)   # this layer's own switch only
    Layers.built?(:name)     # a description file exists
    Layers.names             # every built layer
    Layers.gems              # gems of every built layer, as hashes with `:name` and optional `:version`

## Adding a layer to the registry
Every layer ships `rails/layers/<name>.md` with its front matter and appends its entry to the manifest in `template.rb`:

    manifest = "layers/0-manifest.yml"
    append_to_file manifest, %(LAYER_<NAME>: "false"\n) unless File.read(manifest).include?("LAYER_<NAME>:")

## Testing
`bundle exec rspec spec/layer_registry`
