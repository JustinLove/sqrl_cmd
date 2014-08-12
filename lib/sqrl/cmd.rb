require "sqrl/cmd/version"
require "sqrl/client_session"
require "sqrl/authentication_query_generator"
require "sqrl/authentication_response_parser"
require "thor"
require "httpclient"

module SQRL
  class Cmd < Thor
    desc 'sign url', 'Sign the provided url'
    def sign(url)
      session = ClientSession.new(url, 'x'*32)
      request = AuthenticationQueryGenerator.new(session, url)
      p request.client_data
      puts "POST #{request.post_path}\n\n"
      puts request.post_body

      request
    end

    desc 'post sqrl url', 'Sign the provided url and show the server response'
    def post(url)
      verbose_request(url)
    end

    desc 'attempt one-step login', 'Sign the provided url and attempt to complete login'
    def login(url)
      verbose_request(url) {|req| req.login!}
    end

    desc 'attempt second-loop login', 'Sign the provided url and attempt to complete login'
    def loopin(url)
      session = ClientSession.new(url, 'x'*32)
      verbose_request(url, session)
      verbose_request(url, session) {|req| req.login!}
    end

    desc 'attempt to logoff', 'Sign the provided url and issue a logoff command'
    def logoff(url)
      verbose_request(url) {|req| req.logoff!}
    end

    private
    def verbose_request(url, session = nil)
      session ||= ClientSession.new(url, 'x'*32)
      req = AuthenticationQueryGenerator.new(session, url)
      req = yield req if block_given?
      p req.client_data
      puts "POST #{req.post_path}\n\n"
      puts req.post_body
      res = HTTPClient.new.post(req.post_path, req.post_body)
      puts "Response: #{res.status}"
      puts res.body

      parsed = AuthenticationResponseParser.new(session, res.body)
      p parsed.params
    rescue Errno::ECONNREFUSED => e
      puts e.message
    end
  end
end
