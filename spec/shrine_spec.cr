require "./spec_helper"

describe "Shrine" do
  describe ".with_file" do
    context "given a file" do
      it "yields the given object" do
        Shrine.with_file(test_image) do |file|
          file.should be_a(File)
          file.closed?.should be_false
          test_image.path.should eq(file.path)
        end
      end
    end
  end

  context "given an uploaded file instance" do
    it "downloads the uploaded file" do
      uploaded_file = uploader.upload(fakeio("uploaded_file"))

      Shrine.with_file(uploaded_file) do |file|
        file.should be_a(File)
        file.closed?.should be_false
        file.gets_to_end.should eq("uploaded_file")
      end
    end
  end

  context "given an io stream" do
    it "creates and yields a tempfile" do
      Shrine.with_file(fakeio("file_from_io")) do |file|
        file.should be_a(File)
        file.closed?.should be_false
        file.gets_to_end.should eq("file_from_io")
        file.path.should match(/^#{Dir.tempdir}\/*/)
      end
    end
  end
end
