module SQRL
  class Cmd
    desc 'remove URL', 'Remove SQRL association, requires unlock keys'
    def remove(url)
      session = create_session(url)

      res = verbose_request(session.server_string, session) {|req| req.query! }
      standard_display res

      if res.suk? && identity_unlock_key?
        suk = Key::ServerUnlock.new(res.suk)
        ursk = Key::UnlockRequestSigning.new(suk, identity_unlock_key)
        standard_display verbose_request(session.server_string, session) {|req|
          req.remove!.unlock(ursk)
        }
      end
    end
  end
end
