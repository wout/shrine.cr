require "../spec_helper"

Spectator.describe Shrine::Attacher do
  # include ShrineHelpers
  include FileHelpers

  let(attacher) {
    Shrine::Attacher.new(**NamedTuple.new)
  }

  after_each do
    clear_storages
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
      file = attacher.assign(fakeio)
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
    context "with IO | Shrine::UploadedFile object" do
      it "caches an IO object" do
        attacher.attach_cached(fakeio)

        expect(attacher.file.not_nil!.storage_key).to eq("cache")
      end

      it "caches an UploadedFile object" do
        cached_file = Shrine.upload(fakeio, "cache")
        attacher.attach_cached(cached_file)

        expect(attacher.file.not_nil!.id).to_not eq(cached_file.id)
      end

      it "returns the attached file" do
        file = attacher.attach_cached(fakeio)

        expect(file).to eq(attacher.file)
      end

      context "with custom attacher options" do
        let(attacher) {
          Shrine::Attacher.new(cache_key: "other_cache")
        }

        it "uploads to attacher's temporary storage" do
          attacher.attach_cached(fakeio)
          expect(attacher.file.not_nil!.storage_key).to eq("other_cache")
        end
      end

      it "accepts nils" do
        attacher.attach_cached(fakeio)
        attacher.attach_cached(nil)

        expect(attacher.file).to be_nil
      end

      it "forwards additional options for upload" do
        attacher.attach_cached(fakeio, location: "foo")

        expect(attacher.file.not_nil!.id).to eq("foo")
      end
    end

    context "with uploaded file data" do
      it "accepts JSON data of a cached file" do
        cached_file = Shrine.upload(fakeio, "cache")
        attacher.attach_cached(cached_file.to_json)

        expect(attacher.file).to eq(cached_file)
      end

      it "accepts Hash data of a cached file" do
        cached_file = Shrine.upload(fakeio, "cache")
        attacher.attach_cached(cached_file.data)

        expect(attacher.file).to eq(cached_file)
      end

      it "changes the attachment" do
        cached_file = Shrine.upload(fakeio, "cache")
        attacher.attach_cached(cached_file.data)

        expect(attacher.changed?).to be_true
      end

      it "returns the attached file" do
        cached_file = Shrine.upload(fakeio, "cache")

        expect(attacher.attach_cached(cached_file.data)).to eq(cached_file)
      end

      context "with custom attacher options" do
        let(attacher) {
          Shrine::Attacher.new(cache_key: "other_cache")
        }

        it "uses attacher's temporary storage" do
          cached_file = Shrine.upload(fakeio, "other_cache")
          attacher.attach_cached(cached_file.data)

          expect(attacher.file.not_nil!.storage_key).to eq("other_cache")
        end
      end

      it "rejects non-cached files" do
        stored_file = Shrine.upload(fakeio, "store")

        expect { attacher.attach_cached(stored_file.data) }.to raise_error(Shrine::NotCached)
      end
    end
  end

  describe "#attach" do
    it "uploads the file to permanent storage" do
      attacher.attach(fakeio)

      expect(attacher.file.not_nil!.exists?).to be_true
      expect(attacher.file.not_nil!.storage_key).to eq("store")
    end

    context "with custom attacher options" do
      let(attacher) {
        Shrine::Attacher.new(store_key: "other_cache")
      }

      it "uploads the file to permanent storage" do
        attacher.attach(fakeio)

        expect(attacher.file.not_nil!.exists?).to be_true
        expect(attacher.file.not_nil!.storage_key).to eq("other_cache")
      end
    end

    it "allows specifying a different storage" do
      attacher.attach(fakeio, "other_store")

      expect(attacher.file.not_nil!.exists?).to be_true
      expect(attacher.file.not_nil!.storage_key).to eq("other_store")
    end

    it "forwards additional options for upload" do
      attacher.attach(fakeio, location: "foo")

      expect(attacher.file.not_nil!.id).to eq("foo")
    end

    it "returns the uploaded file" do
      file = attacher.attach(fakeio)

      expect(attacher.file).to eq(file)
    end

    it "changes the attachment" do
      attacher.attach(fakeio)

      expect(attacher.changed?).to be_true
    end

    it "accepts nil" do
      attacher.attach(fakeio)
      attacher.attach(nil)

      expect(attacher.file).to be_nil
    end
  end

  describe "#finalize" do
    it "promotes cached file" do
      attacher.attach_cached(fakeio)
      attacher.finalize

      expect(attacher.file.not_nil!.storage_key).to eq("store")
    end

    it "deletes previous file" do
      previous_file = attacher.attach(fakeio)
      attacher.attach(fakeio)
      attacher.finalize

      expect(previous_file.not_nil!.exists?).to be_false
    end

    it "clears dirty state" do
      attacher.attach(fakeio)
      attacher.finalize

      expect(attacher.changed?).to be_false
    end
  end

  describe "#promote_cached" do
    it "uploads cached file to permanent storage" do
      attacher.attach_cached(fakeio)
      attacher.promote_cached

      expect(attacher.file.not_nil!.storage_key).to eq("store")
    end

    it "doesn't promote if file is not cached" do
      file = attacher.attach(fakeio, storage: "other_store")
      attacher.promote_cached

      expect(attacher.file).to eq(file)
    end

    it "doesn't promote if attachment has not changed" do
      file = Shrine.upload(fakeio, "cache")
      attacher.file = file
      attacher.promote_cached

      expect(attacher.file).to eq(file)
    end

    it "forwards additional options for upload" do
      attacher.attach_cached(fakeio)
      attacher.promote_cached(location: "foo")

      expect(attacher.file.not_nil!.id).to eq("foo")
    end
  end
end
