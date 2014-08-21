require 'sqrl/key/unlock_request_signing'
require 'sqrl/key/server_unlock'

module SQRL
  class Cmd
    desc 'setkey URL', 'Issue setkey command'
    def setkey(url)
      session = ClientSession.new(url, imk)

      res = verbose_request(url, session) {|req| req.setkey!  }
      standard_display res

      if res.command_failed? && res.suk? && identity_unlock_key?
        suk = Key::ServerUnlock.new(res.suk)
        ursk = Key::UnlockRequestSigning.new(suk, identity_unlock_key)
        standard_display verbose_request(url, session) {|req|
          req.setkey!.unlock(ursk)
        }
      end
    end
  end
end
