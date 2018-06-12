# from: https://gist.githubusercontent.com/ulhas/63c5a9b82a456b6e2851/raw/328584cd2898bd62740cb51e0486404110864d20/upload_to_s3.rb

module Fastlane
  module Actions
    class UploadToS3Action < Action
      def self.run(params)
        UI.verbose("AWS Region: #{params[:region]}")
        UI.verbose("AWS Key: #{params[:key]}")
        UI.verbose("AWS File: #{params[:file]}")
        UI.verbose("AWS ACL: #{params[:acl]}")

        # Pulling parameters for other uses
        s3_region = params[:region]
        s3_access_key = params[:access_key]
        s3_secret_access_key = params[:secret_access_key]
        s3_bucket = params[:bucket]
        s3_key = params[:key]
        s3_body = params[:file]
        s3_acl = params[:acl]

        Actions.verify_gem!('aws-sdk')
        require 'aws-sdk'

        if s3_region
          s3_client = Aws::S3::Client.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key,
            region: s3_region
          )
        else
          s3_client = Aws::S3::Client.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key
          )
        end

        UI.message "Beginning upload: #{File.basename(s3_body)}"

        File.open(s3_body, 'r') do |file|
          s3_client.put_object(
            acl: s3_acl,
            bucket: s3_bucket,
            key: s3_key,
            body: file
          )
        end

        UI.success "Uploaded #{File.basename(s3_body)}"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Uploads a file to s3.'
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :region,
                                       env_name: 'S3_AWS_REGION',
                                       description: 'Region for S3',
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       optional: true), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :access_key,
                                       env_name: 'S3_ACCESS_KEY', # The name of the environment variable
                                       description: 'Access Key for S3', # a short description of this parameter
                                       verify_block: proc do |value|
                                         raise "No Access key for UploadToS3Action given, pass using `access_key: 'access_key'`".red unless (value and not value.empty?)
                                       end,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :secret_access_key,
                                       env_name: 'S3_SECRET_ACCESS_KEY', # The name of the environment variable
                                       description: 'Secret Access for S3', # a short description of this parameter
                                       verify_block: proc do |value|
                                         raise "No Secret Access for UploadToS3Action given, pass using `secret_access_key: 'secret_access_key'`".red unless (value and not value.empty?)
                                       end,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :bucket,
                                       env_name: 'S3_BUCKET', # The name of the environment variable
                                       description: 'Bucket for S3', # a short description of this parameter
                                       verify_block: proc do |value|
                                         raise "No Bucket for UploadToS3Action given, pass using `bucket: 'bucket'`".red unless value && !value.empty?
                                       end,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :key,
                                       env_name: '',
                                       description: 'Key to s3 bucket',
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: false), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :acl,
                                       env_name: '',
                                       description: 'Access level for the file',
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       default_value: 'private'),
          FastlaneCore::ConfigItem.new(key: :file,
                                       env_name: '', # The name of the environment variable
                                       description: 'File to be uploaded for S3', # a short description of this parameter
                                       verify_block: proc do |value|
                                         raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end)
        ]
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        %w(ulhas ulhas_sm)
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
