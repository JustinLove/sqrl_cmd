module SQRL
  class Cmd
    desc 'sign URL', 'Print the signed request'
    def sign(url)
      session = ClientSession.new(url, imk)
      request = QueryGenerator.new(session, url)
      p request.client_data
      puts "POST #{request.post_path}\n\n"
      puts request.post_body

      request
    end
  end
end
