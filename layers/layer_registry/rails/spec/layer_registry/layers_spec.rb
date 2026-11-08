require "rails_helper"
require "tmpdir"

RSpec.describe Layers do
  # ENV keys are strings; specs pass symbol-keyed variables.
  def env(**vars) = vars.stringify_keys

  def build(manifest:, layers:, env: {})
    dir = Pathname(Dir.mktmpdir)
    dir.join(Layers::MANIFEST).write(manifest.stringify_keys.to_yaml)
    layers.each do |name, meta|
      front = meta.empty? ? "" : meta.deep_stringify_keys.to_yaml.delete_prefix("---\n")
      dir.join("#{name}.md").write("---\n#{front}---\n# #{name}\n")
    end
    Layers::Registry.new(dir: dir, env: env)
  end

  let(:layers) do
    {
      base: { always_on: true },
      extra: { depends_on: ["base"], gems: [{ name: "rotp", version: "~> 6.3" }] }
    }
  end
  let(:manifest) { { LAYER_BASE: "true", LAYER_EXTRA: "false" } }

  describe "Registry#load_env!" do
    it "sets manifest values in ENV and keeps values already set" do
      vars = env(LAYER_EXTRA: "true")
      build(manifest: manifest, layers: layers, env: vars).load_env!
      expect(vars).to eq(env(LAYER_BASE: "true", LAYER_EXTRA: "true"))
    end
  end

  describe "Registry#enabled?" do
    it "follows ENV" do
      registry = build(manifest: manifest, layers: layers, env: env(LAYER_EXTRA: "on"))
      expect(registry.enabled?(:extra)).to be true
    end

    it "is false when toggled off" do
      expect(build(manifest: manifest, layers: layers, env: env(LAYER_EXTRA: "false")).enabled?(:extra)).to be false
    end

    it "is true for an always_on layer whatever its ENV value" do
      expect(build(manifest: manifest, layers: layers, env: env(LAYER_BASE: "false")).enabled?(:base)).to be true
    end

    it "raises for an unknown layer" do
      expect { build(manifest: manifest, layers: layers).enabled?(:nope) }.to raise_error(Layers::Invalid)
    end
  end

  describe "Registry#gems" do
    it "lists the gems of every built layer" do
      expect(build(manifest: manifest, layers: layers).gems).to eq([{ name: "rotp", version: "~> 6.3" }])
    end
  end

  describe "Registry#validate!" do
    it "passes for a consistent set" do
      expect { build(manifest: manifest, layers: layers, env: {}).validate! }.not_to raise_error
    end

    it "fails when a layer has no manifest entry" do
      registry = build(manifest: { LAYER_BASE: "true" }, layers: layers)
      expect { registry.validate! }.to raise_error(Layers::Invalid, /LAYER_EXTRA/)
    end

    it "fails when a manifest entry has no description" do
      registry = build(manifest: manifest.merge(LAYER_GHOST: "true"), layers: layers)
      expect { registry.validate! }.to raise_error(Layers::Invalid, /LAYER_GHOST/)
    end

    it "fails on an unknown dependency" do
      registry = build(manifest: manifest, layers: layers.merge(extra: { depends_on: ["ghost"] }))
      expect { registry.validate! }.to raise_error(Layers::Invalid, /unknown dependency ghost/)
    end

    it "fails on a dependency cycle" do
      registry = build(
        manifest: { LAYER_A: "false", LAYER_B: "false" },
        layers: { a: { depends_on: ["b"] }, b: { depends_on: ["a"] } }
      )
      expect { registry.validate! }.to raise_error(Layers::Invalid, /cycle/)
    end

    it "fails when a layer is on and its dependency is off" do
      registry = build(
        manifest: { LAYER_A: "true", LAYER_B: "false" },
        layers: { a: { depends_on: ["b"] }, b: {} },
        env: env(LAYER_A: "true", LAYER_B: "false")
      )
      expect { registry.validate! }.to raise_error(Layers::Invalid, /dependency b is off/)
    end
  end

  describe "this app" do
    it "has a valid manifest" do
      expect { Layers.validate! }.not_to raise_error
    end

    it "lists every layer gem in the Gemfile" do
      gemfile = Rails.root.join("Gemfile").read
      missing = Layers.gems.map { |gem| gem[:name] }.reject { |name| gemfile.match?(/^\s*gem ["']#{Regexp.escape(name)}["']/) }
      expect(missing).to be_empty
    end
  end
end
