require "sqrl/cmd/version"
require "sqrl/authentication_query"
require "thor"

module SQRL
  class Cmd < Thor
    desc 'sign url', 'Sign the provided url'
    def sign(url)
      request = AuthenticationQuery.new(url, 'x'*32)
      p request.client_data
      puts "POST #{request.url}\n\n"
      puts request.post_body
    end
  end
end
