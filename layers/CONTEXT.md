# Layers

One folder per layer. A layer is one end-to-end feature implementation, committed together. See [../README.md](../README.md) for registration.

## Front matter

Layer files use [OKF v0.2](https://github.com/GoogleCloudPlatform/open-knowledge-format) front matter. `type: Layer` marks a layer file; `layer`, `parents` and `siblings` are OKF extension keys.

    ---
    type: Layer
    title: Layer Registry
    description: Per-deployment layer toggles.
    tags: [feature]
    layer: layer_registry          # layer name, required
    parents: [other_layer]         # names; must already be registered (earlier commit)
    siblings: [another_layer]      # names; must already be registered; one-way
    generated: { by: human:thom, at: 2026-11-05T00:00:00Z }
    status: stable
    ---

Only files with `type: Layer` register. Payload files under `layers/<name>/rails/` are copied into host apps and carry no layer front matter. `children` is not written by hand; it is filled in when a child registers. A parent must be registered in an earlier commit than its child.

## Structure

    layers/
      CONTEXT.md                 this file
      <layer_name>/
        LAYER.md                 stack-independent description, with OKF front matter (`type: Layer`)
        template.rb              Rails app template that injects the payload
        <stack>/                 one folder per implementation, for example `rails/`
          LAYER.md               stack-specific details; no front matter; not copied into host apps
          ...                    payload, laid out as it will appear in the host app

| Path | Contents |
|------|----------|
| `<layer_name>/` | Snake case, equal to `layer:` in the front matter. |
| `<layer_name>/LAYER.md` | Registers the layer. Concepts, configuration, interface, and a table of implementations. |
| `<layer_name>/template.rb` | Run from the host app root with `bin/rails app:template LOCATION=.../layers/<layer_name>/template.rb`. Points `source_paths` at the stack folder, copies the payload, and excludes `LAYER.md`. |
| `<layer_name>/<stack>/LAYER.md` | Requirements, what injection does, and testing for that stack. |
| `<layer_name>/<stack>/**` | Payload files, copied as is into the host app. |

## Rules

- Only files with `type: Layer` front matter register. Payload files carry none.
- Injection is additive and idempotent. It never deletes host code, and leaves existing host files untouched or prompts on conflict.
- A layer that depends on another lists it in `parents` and must be registered in a later commit.

## Layers

| Layer | Summary |
|-------|---------|
| [layer_registry](layer_registry/LAYER.md) | Per-deployment layer toggles loaded into ENV at boot (`Layers.enabled?`). |
| [routing_and_service_architecture](routing_and_service_architecture/LAYER.md) | `AGENTS.md` routing and per-folder `STANDARDS.md` coding conventions. |
