module SQRL
  class Cmd
    desc 'enable URL', 'Clear disabled status, requires unlock keys'
    def enable(url)
      session = ClientSession.new(url, imk)
      standard_display verbose_request(session.server_string, session) {|req|
        req.enable!
      }
    end
  end
end
