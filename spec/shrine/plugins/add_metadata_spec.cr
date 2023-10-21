require "../../spec_helper"
require "../../../src/shrine/plugins/add_metadata"

describe Shrine::Plugins::AddMetadata do
  it "adds declared metadata" do
    metadata = test_metadata_uploader.extract_metadata(fakeio)

    metadata["custom"].should eq("value")
    metadata["size"].should be_a(Int32)
  end

  it "adds the metadata method to UploadedFile" do
    uploaded_file = test_metadata_uploader.upload(fakeio)

    uploaded_file.metadata["custom"].should eq("value")
  end

  describe "with argument" do
    it "adds declared metadata" do
      metadata = test_metadata_uploader.extract_metadata(fakeio)

      metadata["custom_1"].should eq(fakeio.gets_to_end)
      metadata["custom_2"].should eq(fakeio.gets_to_end * 2)
      metadata["size"].should be_a(Int32)
    end

    it "adds the metadata method to UploadedFile" do
      uploaded_file = test_metadata_uploader.upload(fakeio)

      uploaded_file.metadata["custom_1"].should eq(fakeio.gets_to_end)
      uploaded_file.metadata["custom_2"].should eq(fakeio.gets_to_end * 2)
    end
  end
end

private def test_metadata_uploader
  ShrineWithAddMetadata.new("store")
end

class ShrineWithAddMetadata < Shrine
  load_plugin Shrine::Plugins::AddMetadata

  # Redefine Shrine#extract_metadata to make it public
  def extract_metadata(io : IO, **options) : Shrine::UploadedFile::MetadataType
    super
  end

  add_metadata :custom, ->{
    "value"
  }

  add_metadata :multiple_values, ->{
    text = io.gets_to_end

    Shrine::UploadedFile::MetadataType{
      "custom_1" => text,
      "custom_2" => text * 2,
    }
  }

  finalize_plugins!
end
