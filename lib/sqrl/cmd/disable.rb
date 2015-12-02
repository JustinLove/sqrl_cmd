module SQRL
  class Cmd
    desc 'disable URL', 'Disable ordinary access to your account via SQRL'
    def disable(url)
      session = ClientSession.new(url, imk)
      standard_display verbose_request(session.server_string, session) {|req|
        req.disable!
      }
    end
  end
end
