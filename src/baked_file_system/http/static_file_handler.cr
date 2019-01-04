require "http/server"

class BakedFileSystem::HTTP::StaticFileHandler
    include ::HTTP::Handler

    def initialize(@filesystem : BakedFileSystem, @prefix : String = "/public")
    end

    def call(context)
        requested_path = context.request.path

        return call_next(context) unless requested_path.starts_with?(@prefix)

        file_name = requested_path[@prefix.size..-1]

        if file = @filesystem.get? file_name
            context.response.content_type = file.mime_type
            context.response.content_length = file.size
            context.response.headers.add("Content-Encoding", "gzip") if file.compressed?
            IO.copy(file, context.response)
        else
            call_next(context)
        end
    end
end