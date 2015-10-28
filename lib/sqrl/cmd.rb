require "sqrl/cmd/version"
require "sqrl/client_session"
require "sqrl/query_generator"
require "sqrl/response_parser"
require "thor"
require "logger"


module SQRL
  class Cmd < Thor
    def initialize(*args)
      super
      @log = Logger.new(STDERR)
      @log.level = Logger.const_get(verbose)
      log.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
    end
    attr_reader :log
  end

  require "sqrl/cmd/generate"
  require "sqrl/cmd/keys"
  require "sqrl/cmd/sign"
  require "sqrl/cmd/query"

  require "sqrl/cmd/options"
  require "sqrl/cmd/print"
end
