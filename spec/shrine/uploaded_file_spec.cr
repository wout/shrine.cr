require "../spec_helper"

describe Shrine::UploadedFile do
  before_each do
    clear_storages
  end

  it "initializes metadata if absent" do
    metadata = uploaded_file.metadata
    metadata.should be_a(Shrine::UploadedFile::MetadataType)
  end

  describe "#original_filename" do
    context "without filename in `metadata`" do
      it "returns nil" do
        uploaded_file.original_filename.should be_nil
      end
    end

    context "with filename in `metadata`" do
      it "returns filename from metadata" do
        uploaded_file(metadata: test_metadata(filename: "foo.jpg"))
          .original_filename.should eq("foo.jpg")
      end
    end

    context "with blank filename in `metadata`" do
      it "returns nil" do
        uploaded_file.original_filename.should be_nil
      end
    end
  end

  describe "#extension" do
    context "with extension in `id`" do
      it "returns the extension" do
        uploaded_file("foo.jpg").extension.should eq("jpg")
      end
    end

    context "without extension in `id`" do
      it "returns nil" do
        uploaded_file.extension.should be_nil
      end
    end

    context "with filename and extension in `metadata`" do
      it "returns the extension from metadata" do
        uploaded_file(metadata: test_metadata(filename: "foo.jpg"))
          .extension.should eq("jpg")
      end
    end

    context "with filename in `metadata`" do
      it "returns nil" do
        uploaded_file(metadata: test_metadata(filename: "foo"))
          .extension.should be_nil
      end
    end

    context "with extension in `id` and in `metadata`" do
      it "prefers extension from id over one from filename" do
        uploaded_file("foo.jpg", test_metadata(filename: "foo.png"))
          .extension.should eq("jpg")
      end
    end

    context "with UPCASED extension in `id`" do
      it "downcases the extracted extension" do
        uploaded_file("foo.JPG").extension.should eq("jpg")
      end
    end

    context "with UPCASED extension in `filename`" do
      it "downcases the extracted extension" do
        uploaded_file(metadata: test_metadata(filename: "foo.PNG"))
          .extension.should eq("png")
      end
    end
  end

  describe "#size" do
    context "without size in `metadata`" do
      it "returns nil" do
        uploaded_file.size.should be_nil
      end
    end

    context "with size in `metadata`" do
      it "returns size from metadata" do
        uploaded_file(metadata: test_metadata(size: 50))
          .size.should eq(50)
      end
    end

    context "with size as String in `metadata`" do
      it "converts the value to integer" do
        uploaded_file(metadata: test_metadata(size: "50"))
          .size.should eq(50)
      end
    end
  end

  describe "#mime_type" do
    context "with mime_type in `metadata`" do
      it "returns mime_type from metadata" do
        uploaded_file(metadata: test_metadata(mime_type: "image/jpeg"))
          .mime_type.should eq("image/jpeg")
      end

      it "has #content_type alias" do
        uploaded_file(metadata: test_metadata(mime_type: "image/jpeg"))
          .content_type.should eq("image/jpeg")
      end
    end

    context "with blank mime_type in `metadata`" do
      it "returns nil as a mime_type" do
        uploaded_file.mime_type.should be_nil
      end
    end
  end

  describe "#close" do
    it "closes the underlying IO object" do
      uploaded_file = uploader.upload(fakeio)
      io = uploaded_file.io
      uploaded_file.close

      io.closed?.should be_true
    end
  end

  describe "#url" do
    it "delegates to underlying storage" do
      uploaded_file.url.should eq("memory://foo")
    end
  end

  # describe "#exists?" do
  #   it "delegates to underlying storage" do
  #     uploaded_file = uploader.upload(fakeio)
  #     uploaded_file.exists?.should be_true

  #     subject.exists?.should be_false
  #   end
  # end

  # describe "#open" do
  #   it "returns the underlying IO if no block given" do
  #     uploaded_file = uploader.upload(fakeio)

  #     uploaded_file.open.should be_an(IO)
  #     uploaded_file.open.closed?.should be_false
  #   end

  #   it "closes the previous IO" do
  #     uploaded_file = uploader.upload(fakeio)
  #     io1 = uploaded_file.open
  #     io2 = uploaded_file.open

  #     io1.should_not eq(io2)
  #     io1.closed?.should be_true
  #     io2.closed?.should be_false
  #   end

  #   it "yields to the block if it's given" do
  #     uploaded_file = uploader.upload(fakeio)

  #     called = false
  #     uploaded_file.open { called = true }
  #     called.should be_true
  #   end

  #   it "yields the opened IO" do
  #     uploaded_file = uploader.upload(fakeio("file"))
  #     uploaded_file.open do |io|
  #       io = io.not_nil!

  #       io.should be_an(IO)
  #       io.gets_to_end.should eq("file")
  #     end
  #   end

  #   it "makes itself open as well" do
  #     uploaded_file = uploader.upload(fakeio)
  #     uploaded_file.open do |io|
  #       io.should eq(uploaded_file.io)
  #     end
  #   end

  #   it "closes the IO after block finishes" do
  #     uploaded_file = uploader.upload(fakeio)

  #     dup = IO::Memory.new
  #     uploaded_file.open { |io| dup = io.not_nil! }
  #     ->{ dup.gets_to_end }.should raise_error(IO::Error)
  #   end

  #   it "resets the uploaded file ready to be opened again" do
  #     uploaded_file = uploader.upload(fakeio("file"))
  #     uploaded_file.open { }

  #     uploaded_file.gets_to_end.should eq("file")
  #   end

  #   it "opens even if it was closed" do
  #     uploaded_file = uploader.upload(fakeio("file"))
  #     uploaded_file.gets_to_end
  #     uploaded_file.close
  #     uploaded_file.open { |io|
  #       io.not_nil!.gets_to_end.should eq("file")
  #     }
  #   end

  #   it "closes the file even if an error has occurred" do
  #     uploaded_file = uploader.upload(fakeio)
  #     dup = IO::Memory.new

  #     ->{
  #       uploaded_file.open do |io|
  #         dup = io.not_nil!
  #         raise "error occurred"
  #       end
  #     }.should raise_error(Exception)

  #     dup.closed?.should be_true
  #   end
  # end

  # describe "#download" do
  #   it "downloads file content to a Tempfile" do
  #     uploaded_file = uploader.upload(fakeio("file"))
  #     downloaded = uploaded_file.download

  #     downloaded.should be_a(File)
  #     downloaded.closed?.should be_false
  #     downloaded.gets_to_end.should eq("file")
  #   end

  #   it "applies extension from #id" do
  #     uploaded_file = uploader.upload(fakeio, location: "foo.jpg")

  #     uploaded_file.download.path.should match(/\.jpg$/)
  #   end

  #   it "applies extension from #original_filename" do
  #     uploaded_file = uploader.upload(fakeio(filename: "foo.jpg"), location: "foo")

  #     uploaded_file.download.path.should match(/\.jpg$/)
  #   end

  #   it "yields the tempfile if a block is given" do
  #     uploaded_file = uploader.upload(fakeio)

  #     uploaded_file.download do |tempfile|
  #       block = tempfile

  #       block.should be_a(File)
  #     end
  #   end

  #   it "returns the block return value" do
  #     uploaded_file = uploader.upload(fakeio)

  #     result = uploaded_file.download { |_tempfile| "result" }
  #     result.should eq("result")
  #   end

  #   it "closes and deletes the tempfile after the block" do
  #     uploaded_file = uploader.upload(fakeio)

  #     tempfile = uploaded_file.download do |_tempfile|
  #       _tempfile.closed?.should be_false
  #       _tempfile
  #     end

  #     tempfile.closed?.should be_true
  #     File.exists?(tempfile.path).should be_false
  #   end
  # end

  # describe "#stream" do
  #   it "opens and closes the file after streaming if it was not open" do
  #     uploaded_file = uploader.upload(fakeio("content"))
  #     uploaded_file.stream(destination = IO::Memory.new)

  #     destination.to_s.should eq("content")
  #     uploaded_file.opened?.should be_false
  #   end
  # end

  # describe "#replace" do
  #   it "uploads another file to the same location" do
  #     uploaded_file = uploader.upload(fakeio("file"))
  #     new_uploaded_file = uploaded_file.replace(fakeio("replaced"))

  #     new_uploaded_file.id.should eq(uploaded_file.id)
  #     new_uploaded_file.gets_to_end.should eq("replaced")
  #     new_uploaded_file.size.should eq("replaced".size)
  #   end
  # end

  # describe "#delete" do
  #   it "delegates to underlying storage" do
  #     uploaded_file = uploader.upload(fakeio)
  #     uploaded_file.delete

  #     uploaded_file.exists?.should be_false
  #   end
  # end

  # describe "#data" do
  #   metadata = {
  #     "foo" => "bar",
  #   }

  #   it "returns uploaded file data hash" do
  #     uploaded_file.data.should eq(
  #       {
  #         "id"          => id,
  #         "storage_key" => "cache",
  #         "metadata"    => metadata,
  #       }
  #     )
  #   end
  # end
end

private def uploaded_file(
  id : String? = nil,
  metadata : TestMetadata? = nil
)
  Shrine::UploadedFile.new(id || "foo", "cache", metadata || test_metadata)
end

private def test_id
  "foo"
end

private def test_metadata(
  filename : String? = nil,
  mime_type : String? = nil,
  size : String | Int? = nil
)
  TestMetadata.new.merge({
    "filename"  => filename,
    "mime_type" => mime_type,
    "size"      => size,
  })
end
