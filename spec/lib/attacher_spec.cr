require "../spec_helper"

Spectator.describe Shrine::Attacher do
  include ShrineHelpers
  include FileHelpers

  let(:attacher_options) { NamedTuple.new }
  let(:attacher) {
    Shrine::Attacher.new(**attacher_options)
  }

  after_all do
    Shrine.settings.storages["cache"].as(Shrine::Storage::Memory).clear!
    Shrine.settings.storages["store"].as(Shrine::Storage::Memory).clear!
  end

  describe ".from_data" do
    it "instantiates an attacher from file data" do
      file = attacher.upload(fakeio)

      expect(
        Shrine::Attacher.from_data(file.data).file
      ).to eq(file)
    end

    it "forwards additional options to .new" do
      expect(
        Shrine::Attacher.from_data(nil, cache_key: "other_cache").cache_key
      ).to eq("other_cache")
    end
  end

  describe "#assign" do
    it "attaches a file to cache" do
      attacher.assign(fakeio)

      expect(attacher.file.not_nil!.storage_key).to eq("cache")
    end

    it "returns the cached file" do
      file = attacher.assign(fakeio)

      expect(file).to eq(attacher.file)
    end

    # it "ignores empty strings" do
    #   attacher.assign(fakeio)
    #   attacher.assign("")

    #   expect(attacher.attached?).to be_true
    # end

    it "accepts nil" do
      attacher.assign(fakeio)
      attacher.assign(nil)

      expect(attacher.attached?).to be_false
    end

    it "fowards any additional options for upload" do
      attacher.assign(fakeio, location: "foo")

      expect(attacher.file.not_nil!.id).to eq("foo")
    end
  end

  describe "#attach_cached" do
    describe "with IO object" do
      it "caches an IO object" do
        attacher.attach_cached(fakeio)

        expect(attacher.file.not_nil!.storage_key).to eq("cache")
      end
    end
  end
end
