class Shrine
  module Plugins
    module Column
      # DEFAULT_OPTIONS = {
      #   serializer: JsonSerializer
      # }
      # def self.configure(uploader, **opts)
      #   uploader.opts[:column] ||= { serializer: JsonSerializer }
      #   uploader.opts[:column].merge!(opts)
      # end

      module AttacherClassMethods
        # Initializes the attacher from a data hash/string expected to come
        # from a database record column.
        #
        #     Attacher.from_column('{"id":"...","storage":"...","metadata":{...}}')
        def from_column(data, **options) : Attacher | Nil
          attacher = new(**options)
          attacher.load_column(data)
          attacher
        end
      end

      module AttacherMethods
        # Column serializer object.
        # getter :column_serializer

        # Allows overriding the default column serializer.
        # def initialize(@column_serializer = self.class.shrine_class.plugin_settings.column[:serializer], **options)
        #   super(**options)
        #   # @column_serializer = column_serializer
        # end

        # Loads attachment from column data.
        #
        #     attacher.file #=> nil
        #     attacher.load_column('{"id":"...","storage":"...","metadata":{...}}')
        #     attacher.file #=> #<Shrine::UploadedFile>
        def load_column(data : String) : UploadedFile
          load_data(Hash(String, String | UploadedFile::MetadataType).from_json(data))
        end

        def load_column(data : Nil) : Nil
          load_data(data)
        end

        # Returns attacher data as a serialized string (JSON by default).
        #
        #     attacher.column_data #=> '{"id":"...","storage":"...","metadata":{...}}'
        def column_data
          # serialize_column(data)
          data.try &.to_json
        end

        # Converts the column data hash into a string (generates JSON by
        # default).
        #
        #     Attacher.serialize_column({ "id" => "...", "storage" => "...", "metadata" => { ... } })
        #     #=> '{"id":"...","storage":"...","metadata":{...}}'
        #
        #     Attacher.serialize_column(nil)
        #     #=> nil
        private def serialize_column(data)
          if column_serializer && data
            column_serializer.dump(data)
          else
            data
          end
        end

        # Converts the column data string into a hash (parses JSON by default).
        #
        #     Attacher.deserialize_column('{"id":"...","storage":"...","metadata":{...}}')
        #     #=> { "id" => "...", "storage" => "...", "metadata" => { ... } }
        #
        #     Attacher.deserialize_column(nil)
        #     #=> nil
        # private def deserialize_column(data)
        #   if column_serializer && data && !data.is_a?(Hash)
        #     column_serializer.load(data)
        #   else
        #     data.to_hash
        #   end
        # end
      end

      # JSON.dump and JSON.load shouldn't be used with untrusted input, so we
      # create this wrapper class which calls JSON.generate and JSON.parse
      # instead.
      class JsonSerializer
        def self.dump(data)
          data.to_json
        end

        def self.load(data)
          JSON.parse(data)
        end
      end
    end
  end
end