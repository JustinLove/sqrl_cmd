require "sqrl/cmd/version"
require "sqrl/client_session"
require "sqrl/authentication_query_generator"
require "sqrl/authentication_response_parser"
require "thor"
require "httpclient"
require "logger"

module SQRL
  class Cmd < Thor
    LogLevels = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN]
    class_option :verbose, :default => 'WARN', :desc => 'DEBUG, INFO, WARN'

    def initialize(*args)
      super
      @log = Logger.new(STDERR)
      @log.level = Logger.const_get(verbose)
      log.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
    end
    attr_reader :log

    desc 'sign [URL]', 'Print the signed request'
    def sign(url)
      session = ClientSession.new(url, 'x'*32)
      request = AuthenticationQueryGenerator.new(session, url)
      p request.client_data
      puts "POST #{request.post_path}\n\n"
      puts request.post_body

      request
    end

    desc 'post [URL]', 'Show server response'
    def post(url)
      parsed = verbose_request(url)
      p parsed.params
    end

    desc 'login [URL]', 'Attempt single-loop login'
    def login(url)
      parsed = verbose_request(url) {|req| req.login!}
      puts parsed.server_friendly_name
      puts parsed.tif.to_s(16)
    end

    desc 'loopin [URL]', 'Attempt double-loop login'
    def loopin(url)
      session = ClientSession.new(url, 'x'*32)
      parsed = verbose_request(url, session)
      puts parsed.tif.to_s(16)
      return unless yes?("log in to '#{parsed.server_friendly_name}'?")
      parsed = verbose_request(url, session) {|req| req.login!}
      puts parsed.tif.to_s(16)
    end

    desc 'logoff [URL]', 'Issue logoff command'
    def logoff(url)
      parsed = verbose_request(url) {|req| req.logoff!}
      puts parsed.server_friendly_name
      puts parsed.tif.to_s(16)
    end

    private
    def verbose_request(url, session = nil)
      session ||= ClientSession.new(url, 'x'*32)
      req = AuthenticationQueryGenerator.new(session, url)
      req = yield req if block_given?
      log.debug req.client_data.inspect
      log.debug "POST #{req.post_path}\n\n"
      log.debug req.post_body
      res = HTTPClient.new.post(req.post_path, req.post_body)
      log.debug "Response: #{res.status}"
      log.debug res.body

      parsed = AuthenticationResponseParser.new(session, res.body)
      log.info parsed.params.inspect
      parsed
    rescue Errno::ECONNREFUSED => e
      log.error e.message
      AuthenticationResponseParser.new(session, {'exception' => e})
    end

    def verbose
      ([options[:verbose].to_s.upcase, "WARN"] & LogLevels).compact.first
    end
  end
end
