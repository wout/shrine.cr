# frozen_string_literal: true

class Shrine
  # Core class that handles attaching files. It uses Shrine and
  # Shrine::UploadedFile objects internally.
  class Attacher
    # @shrine_class = ::Shrine
    # Returns the Shrine class that this attacher class is namespaced
    # under.
    class_property shrine_class : Shrine.class = Shrine

    module ClassMethods

      # Initializes the attacher from a data hash generated from `Attacher#data`.
      #
      #     attacher = Attacher.from_data({ "id" => "...", "storage" => "...", "metadata" => { ... } })
      #     attacher.file #=> #<Shrine::UploadedFile>
      def from_data(data, **options)
        attacher = new(**options)
        attacher.load_data(data)
        attacher
      end
    end

    module InstanceMethods
      # Returns the attached uploaded file.
      getter :file

      # Returns options that are automatically forwarded to the uploader.
      # Can be modified with additional data.
      getter :context

      getter :store_key

      # Initializes the attached file, temporary and permanent storage.
      def initialize(@file : Shrine::UploadedFile? = nil, @cache_ket : String = "cache", @store_key : String = "store")
        # @file = file
        # @cache = cache
        # @store = store
        @context = Hash(String, String).new
      end

      # Delegates to `Shrine.upload`, passing the #context.
      #
      #     # upload file to specified storage
      #     attacher.upload(io, "store") #=> #<Shrine::UploadedFile>
      #
      #     # pass additional options for the uploader
      #     attacher.upload(io, "store", metadata: { "foo" => "bar" })
      def upload(io : IO, storage = store_key, **options)
        # shrine_class.upload(io, storage, **context, **options)
        shrine_class.upload(io, storage, **options)
      end

      # Returns the Shrine class that this attacher's class is namespaced
      # under.
      def shrine_class
        self.class.shrine_class
      end
    end

    extend ClassMethods
    include InstanceMethods
  end
end
