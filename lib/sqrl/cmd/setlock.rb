require "sqrl/base64"

module SQRL
  class Cmd
    desc 'setlock [URL]', 'Send the server and verify unlock keys'
    def setlock(url)
      response = verbose_request(url) {|req|
        req.setlock!(identity_lock_key.unlock_pair)
      }
      standard_display response
      puts Base64.encode(response.suk)
    end
  end
end
