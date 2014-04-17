require "sqrl/cmd/version"
require "sqrl/authentication_query"
require "thor"
require "httpclient"

module SQRL
  class Cmd < Thor
    desc 'sign url', 'Sign the provided url'
    def sign(url)
      request = AuthenticationQuery.new(url, 'x'*32)
      p request.client_data
      puts "POST #{request.url}\n\n"
      puts request.post_body

      request
    end

    desc 'post login', 'Sign the provided url and attempt to log in'
    def post(url)
      request = sign(url)
      response = HTTPClient.new.post(request.url, request.post_body)
      puts response.body
      puts "Response: #{response.status}"
    end
  end
end
