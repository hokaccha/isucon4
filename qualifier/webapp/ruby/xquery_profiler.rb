require 'mysql2-cs-bind'
require 'logger'
require 'json'

class XQueryProfiler
  def self.enable!(output_to:)
    @output_filepath = output_to
    Mysql2::Client.prepend Logging
  end

  def self.output_filepath
    @output_filepath
  end

  module Logging
    def xquery(sql, *args)
      file, line = parse_caller caller[0]

      start = Time.now
      result = super
      duration = Time.now - start

      logger.info(sql:sql, file: "#{file}:#{line}", duration: duration)

      result
    end

    private

    def logger
      return @logger if @logger
      @logger = Logger.new XQueryProfiler.output_filepath
      @logger.formatter = proc { |severity, datetime, progname, message|
        message.to_json + "\n"
      }
      @logger
    end

    def parse_caller(at)
      if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
        file = $1
        line = $2.to_i
        method = $3
        [file, line, method]
      end
    end
  end
end
