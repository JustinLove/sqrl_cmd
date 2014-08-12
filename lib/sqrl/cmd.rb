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
      session = ClientSession.new(url, imk)
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

    desc 'login [URL]', 'Attempt login'
    long_desc <<-LONGDESC
      loops=1: The first request to the server includes the login command

      loops=2: Send a request with no command, and then prompt the user whether to login using the server friendly name.
    LONGDESC
    option :loops, :type => :numeric, :default => 2,
      :desc => "1: direct, 2: check server first"
    def login(url)
      session = ClientSession.new(url, imk)

      if options[:loops] >= 2
        parsed = verbose_request(url, session)
        puts parsed.tif.to_s(16)
        return unless yes?("log in to '#{parsed.server_friendly_name}'?")
      end

      parsed = verbose_request(url, session) {|req| req.login!}
      puts parsed.server_friendly_name
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
      session ||= ClientSession.new(url, imk)
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

    def imk
      'x'.b*32
    end
  end
end
