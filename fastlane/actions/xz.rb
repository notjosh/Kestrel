# Based on default 'zip' action, but modified for .tar.xz

module Fastlane
  module Actions
    class XzAction < Action
      def self.run(params)
        UI.message "Compressing #{params[:path]}..."

        params[:output_path] ||= File.join(Dir.pwd, "#{params[:path]}.tar.xz")

        Dir.chdir(File.expand_path('..', params[:path])) do # required to properly archive
          Actions.sh "tar -cJf #{params[:output_path].shellescape} #{File.basename(params[:path]).shellescape}"
        end

        UI.success "Successfully generated .tar.xz file at path '#{File.expand_path(params[:output_path])}'"
        return File.expand_path(params[:output_path])
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Compress a file or folder to a .tar.xz"
      end

      def self.details
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_XZ_PATH",
                                       description: "Path to the directory or file to be xzipped",
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file/folder at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                       env_name: "FL_XZ_OUTPUT_NAME",
                                       description: "The name of the resulting .tar.xz file",
                                       optional: true)
        ]
      end

      def self.example_code
        [
          'zip',
          'zip(
            path: "MyApp.app",
            output_path: "Latest.app.tar.xz"
          )'
        ]
      end

      def self.category
        :misc
      end

      def self.output
        []
      end

      def self.return_value
        "The path to the output tar.xz file"
      end

      def self.authors
        ["KrauseFx", "notjosh"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
