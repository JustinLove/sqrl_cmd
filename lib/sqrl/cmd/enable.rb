module SQRL
  class Cmd
    desc 'enable URL', 'Clear disabled status, requires unlock keys'
    def enable(url)
      session = ClientSession.new(url, imk)

      res = verbose_request(session.server_string, session) {|req| req.query! }
      standard_display res

      if res.suk? && identity_unlock_key?
        suk = Key::ServerUnlock.new(res.suk)
        ursk = Key::UnlockRequestSigning.new(suk, identity_unlock_key)
        standard_display verbose_request(session.server_string, session) {|req|
          req.enable!.unlock(ursk)
        }
      end
    end
  end
end
