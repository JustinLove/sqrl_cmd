require "sqrl/cmd/version"
require "sqrl/client_session"
require "sqrl/authentication_query_generator"
require "sqrl/authentication_response_parser"
require "thor"
require "httpclient"

module SQRL
  class Cmd < Thor
    desc 'sign [URL]', 'Print the signed request'
    def sign(url)
      session = ClientSession.new(url, 'x'*32)
      request = AuthenticationQueryGenerator.new(session, url)
      p request.client_data
      puts "POST #{request.post_path}\n\n"
      puts request.post_body

      request
    end

    desc 'post [URL]', 'Show request andserver response'
    def post(url)
      verbose_request(url)
    end

    desc 'login [URL]', 'Attempt single-loop login'
    def login(url)
      verbose_request(url) {|req| req.login!}
    end

    desc 'loopin [URL]', 'Attempt double-loop login'
    def loopin(url)
      session = ClientSession.new(url, 'x'*32)
      verbose_request(url, session)
      verbose_request(url, session) {|req| req.login!}
    end

    desc 'logoff [URL]', 'Issue logoff command'
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
