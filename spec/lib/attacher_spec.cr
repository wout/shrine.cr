require "../spec_helper"

Spectator.describe Shrine::Attacher do
  include ShrineHelpers
  include FileHelpers



  describe ".from_data" do
    it "instantiates an attacher from file data" do
      file = attacher.upload(fakeio)
      attacher = Shrine::Attacher.from_data(file.data)
      assert_equal file, attacher.file
    end
  end
end
