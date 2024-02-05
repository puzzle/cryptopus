module ActiveSupport
  module TaggedLogging
    module Formatter
      # Hide Encryptable#encrypted_data column from SQL queries because it's huge.
      def scrub_encrypted_data_source(input)
        input.gsub(/\["encrypted_data", ".*, \["/, '["encrypted_data", "REDACTED"], ["')
      end

      alias orig_call call

      def call(severity, timestamp, progname, msg)
        orig_call(severity, timestamp, progname, scrub_encrypted_data_source(msg))
      end
    end
  end
end
