require "sqrl/base64"
require 'sqrl/key/unlock_request_signing'
require 'sqrl/key/server_unlock'

module SQRL
  class Cmd
    desc 'setlock URL', 'Send the server and verify unlock keys'
    def setlock(url)
      session = ClientSession.new(url, imk)

      res = verbose_request(url, session) {|req|
        req.setlock!(identity_lock_key.unlock_pair)
      }
      standard_display res
      puts Base64.encode(res.suk)

      if res.command_failed? && res.suk? && identity_unlock_key?
        suk = Key::ServerUnlock.new(res.suk)
        ursk = Key::UnlockRequestSigning.new(suk, identity_unlock_key)
        res =  verbose_request(url, session) {|req|
          req.setlock!(identity_lock_key.unlock_pair).unlock(ursk)
        }
        standard_display res
        puts Base64.encode(res.suk)
      end
    end
  end
end
