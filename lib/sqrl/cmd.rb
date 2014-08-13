require "sqrl/cmd/version"
require "sqrl/tif"
require "sqrl/client_session"
require "sqrl/authentication_query_generator"
require "sqrl/authentication_response_parser"
require "sqrl/key/identity_master"
require "sqrl/key/identity_unlock"
require "sqrl/base64"
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

    desc 'post [URL]', 'Query server status with no command'
    def post(url)
      standard_display verbose_request(url)
    end

    desc 'setkey [URL]', 'Issue setkey command'
    def setkey(url)
      standard_display verbose_request(url) {|req| req.setkey!}
    end

    desc 'setlock [URL]', 'Send the server and verify unlock keys'
    def setlock(url)
      response = verbose_request(url) {|req|
        req.setlock!(identity_lock_key.unlock_pair)
      }
      standard_display response
      puts Base64.encode(response.suk)
    end

    desc 'create [URL]', 'Create a new account on the system'
    option :only, :type => :boolean,
      :desc => "do not issue setkey/setlock"
    option :login, :type => :boolean,
      :desc => "Immediately login"
    def create(url)
      session = ClientSession.new(url, imk)

      standard_display verbose_request(url, session) {|req|
        req.create!
        unless options[:only]
          req.setkey!.setlock!(identity_lock_key.unlock_pair)
        end
        req.login! if options[:login]
        req
      }
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
        print_tif(parsed.tif)
        unless parsed.id_match?
          puts "Abort, ID not known"
          return
        end
        return unless yes?("log in to '#{parsed.server_friendly_name}'?")
      end

      standard_display verbose_request(url, session) {|req| req.login!}
    end

    desc 'logout [URL]', 'Issue logout command'
    option :logoff, :type => :boolean
    def logout(url)
      standard_display verbose_request(url) {|req|
        if options[:logoff]
          req.logoff!
        else
          req.logout!
        end
      }
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

    def print_tif(tif)
      print_table SQRL::TIF.map {|bit, flag|
        if (tif & bit) != 0
          [bit.to_s(16), flag.to_s.upcase]
        else
          ['  ', flag]
        end
      }
    end

    def standard_display(parsed)
      puts parsed.server_friendly_name
      print_tif(parsed.tif)
    end

    def imk
      Key::IdentityMaster.new('x'.b*32)
    end

    def identity_unlock_key
      Key::IdentityUnlock.new('x'.b*32)
    end

    def identity_lock_key
      @ilk ||= identity_unlock_key.identity_lock_key
    end
  end
end
