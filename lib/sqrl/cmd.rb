require "sqrl/cmd/version"
require "sqrl/client_session"
require "sqrl/authentication_query_generator"
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
  end
end
