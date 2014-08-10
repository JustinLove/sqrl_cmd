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
      request = sign(url)
      response = HTTPClient.new.post(request.post_path, request.post_body)
      puts response.body
      puts "Response: #{response.status}"
    end

    desc 'attempt one-step login', 'Sign the provided url and attempt to complete login'
    def login(url)
      session = ClientSession.new(url, 'x'*32)
      req1 = AuthenticationQueryGenerator.new(session, url).login!
      p req1.client_data
      puts "POST #{req1.post_path}\n\n"
      puts req1.post_body
      res1 = HTTPClient.new.post(req1.post_path, req1.post_body)
      puts "Response 1: #{res1.status}"
      puts res1.body

      parsed = AuthenticationResponseParser.new(session, res1.body)
      p parsed.params
    end

    desc 'attempt second-loop login', 'Sign the provided url and attempt to complete login'
    def loopin(url)
      req1 = sign(url)
      res1 = HTTPClient.new.post(req1.post_path, req1.post_body)
      puts res1.body
      puts "Response 1: #{res1.status}"

      req2 = SQRL::AuthenticationQueryGenerator.new(req1.session, res1.body).login!
      p req2.client_data
      puts "POST #{req2.post_path}\n\n"
      puts req2.post_body
      res2 = HTTPClient.new.post(req2.post_path, req2.post_body)
      puts res2.body
      puts "Response 2: #{res2.status}"
    end
  end
end
