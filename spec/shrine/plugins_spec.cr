require "../spec_helper"

describe "Shrine.plugin" do
  describe NonPluginUploader do
    it "responds to .foo with :foo" do
      NonPluginUploader.responds_to?(:foo).should be_true
      NonPluginUploader.foo.should eq("foo")
    end

    it "responds to #foo with :foo" do
      uploader_instance = NonPluginUploader.new("store")

      uploader_instance.responds_to?(:foo).should be_true
      uploader_instance.foo.should eq("foo")
    end
  end

  describe PluginUploader do
    it "responds to .foo with :foo" do
      PluginUploader.responds_to?(:foo).should be_true
      PluginUploader.foo.should eq("plugin_foo")
    end

    it "responds to #foo with :foo" do
      uploader_instance = PluginUploader.new("store")

      uploader_instance.responds_to?(:foo).should be_true
      uploader_instance.foo.should eq("plugin_foo")
    end
  end

  describe PluginUploader::UploadedFile do
    it "responds to .foo with :foo" do
      uploaded_file = PluginUploader::UploadedFile

      uploaded_file.responds_to?(:foo).should be_true
      uploaded_file.foo.should eq("plugin_foo")
    end

    it "does not pollute superclass" do
      Shrine::UploadedFile.responds_to?(:foo).should be_false
    end
  end
end

module FooPlugin
  module ClassMethods
    def foo
      "plugin_foo"
    end
  end

  module InstanceMethods
    def foo
      "plugin_foo"
    end
  end

  module FileClassMethods
    def foo
      "plugin_foo"
    end
  end

  module FileMethods
    def foo
      "plugin_foo"
    end
  end
end

class NonPluginUploader < Shrine
  module ClassMethods
    def foo
      "foo"
    end
  end

  module InstanceMethods
    def foo
      "foo"
    end
  end

  extend ClassMethods
  include InstanceMethods
end

class PluginUploader < NonPluginUploader
  load_plugin ::FooPlugin
  finalize_plugins!
end
