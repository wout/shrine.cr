require "../../spec_helper"

class ShrineWithColumn < Shrine
  load_plugin(Shrine::Plugins::Column)

  finalize_plugins!
end


Spectator.describe Shrine::Plugins::Column do
  include FileHelpers

  let(attacher) {
    ShrineWithColumn::Attacher.new(**NamedTuple.new)
  }

  describe ".from_column" do
    it "loads file from column data" do
      file = attacher.upload(fakeio)
      attacher = ShrineWithColumn::Attacher.from_column(file.to_json)

      expect(attacher.file).to eq(file)
    end

    it "forwards additional options to .new" do
      expect(
        ShrineWithColumn::Attacher.from_column(nil, cache_key: "other_cache").cache_key
      ).to eq("other_cache")
    end
  end

  # describe "#initialize" do
  #   it "accepts a serializer" do
  #     attacher = @shrine::Attacher.new(column_serializer: :my_serializer)

  #     assert_equal :my_serializer, attacher.column_serializer
  #   end

  #   it "accepts nil serializer" do
  #     attacher = @shrine::Attacher.new(column_serializer: nil)

  #     assert_nil attacher.column_serializer
  #   end

  #   it "uses plugin serializer as default" do
  #     @shrine.plugin :column, serializer: RubySerializer
  #     assert_equal RubySerializer, @shrine::Attacher.new.column_serializer

  #     @shrine.plugin :column, serializer: nil
  #     assert_nil @shrine::Attacher.new.column_serializer
  #   end
  # end

  describe "#load_column" do
    it "loads file from serialized file data" do
      file = attacher.upload(fakeio)
      attacher.load_column(file.to_json)

      expect(attacher.file).to eq(file)
    end

    it "clears file when nil is given" do
      attacher.attach(fakeio)
      attacher.load_column(nil)

      expect(attacher.file).to be_nil
    end

    # it "handles hashes" do
    #   file = attacher.attach(fakeio)
    #   attacher.load_column(file.not_nil!.data)

    #   expect(attacher.file).to eq(file)
    # end
  end

  describe "#column_data" do
    it "returns serialized file data" do
      attacher.attach(fakeio)

      expect(attacher.column_data).to eq(attacher.file.to_json)
    end

    it "returns nil when no file is attached" do
      expect(attacher.column_data).to be_nil
    end
  end


end