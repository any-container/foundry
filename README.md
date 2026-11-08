# Agentic Foundry

Relational index of layers. A layer is one end-to-end feature implementation, committed together; its git commit SHA is its id.

## Front matter

See [layers/CONTEXT.md](layers/CONTEXT.md).

## Registration

PRs labelled `layer` run `.github/workflows/create-layer.yml`. It runs `ruby register_layer.rb <head sha>`, commits `foundry.sqlite3` to the PR branch, and comments the short SHA with success or failure.

Local run: `gem install sqlite3 && ruby register_layer.rb`.

The script reads `layers/` in this repository's git history. Rows registered before the move from `any-container/rails-template` carry that repository's commit SHAs as ids.
