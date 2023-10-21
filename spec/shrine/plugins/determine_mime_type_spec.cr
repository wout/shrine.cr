require "../../spec_helper"
require "../../../src/shrine/plugins/determine_mime_type"

describe Shrine::Plugins::DetermineMimeType do
  context "file analyzer" do
    subject = ShrineWithDetermineMimeTypeFile

    it "determines MIME type from file contents" do
      subject.determine_mime_type(test_image)
        .should eq("image/png")
    end

    it "returns text/plain for unidentified MIME types" do
      subject.determine_mime_type(fakeio("a" * 1024))
        .should eq("text/plain")
    end

    it "is able to determine MIME type for non-files" do
      subject.determine_mime_type(fakeio(test_image.gets_to_end))
        .should eq("image/png")
    end

    it "returns nil for empty IOs" do
      subject.determine_mime_type(fakeio(""))
        .should be_nil
    end
  end

  context "mime analyzer" do
    subject = ShrineWithDetermineMimeTypeMime

    it "extract MIME type from the file extension" do
      subject.determine_mime_type(fakeio(filename: "image.png"))
        .should eq("image/png")

      subject.determine_mime_type(test_image)
        .should eq("image/png")
    end

    it "extracts MIME type from the file extension when IO is empty" do
      subject.determine_mime_type(fakeio("", filename: "image.png"))
        .should eq("image/png")
    end

    it "returns nil on an unknown extension" do
      subject.determine_mime_type(fakeio(filename: "image.foo"))
        .should be_nil
    end

    it "returns nil when input is not a file" do
      subject.determine_mime_type(fakeio)
        .should be_nil
    end
  end
end

class ShrineWithDetermineMimeTypeFile < Shrine
  load_plugin(Shrine::Plugins::DetermineMimeType,
    analyzer: Shrine::Plugins::DetermineMimeType::Tools::File)

  finalize_plugins!
end

class ShrineWithDetermineMimeTypeMime < Shrine
  load_plugin(Shrine::Plugins::DetermineMimeType,
    analyzer: Shrine::Plugins::DetermineMimeType::Tools::Mime)

  finalize_plugins!
end
