require "sqrl/cmd/version"
require "sqrl/client_session"
require "sqrl/authentication_query_generator"
require "sqrl/authentication_response_parser"
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

  require "sqrl/cmd/sign"
  require "sqrl/cmd/post"
  require "sqrl/cmd/setkey"
  require "sqrl/cmd/setlock"
  require "sqrl/cmd/create"
  require "sqrl/cmd/login"
  require "sqrl/cmd/logout"

  require "sqrl/cmd/options"
  require "sqrl/cmd/print"
  require "sqrl/cmd/keys"
end
