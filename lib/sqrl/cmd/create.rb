module SQRL
  class Cmd
    desc 'create [URL]', 'Create a new account on the system'
    option :only, :type => :boolean,
      :desc => "do not issue setkey/setlock"
    option :login, :type => :boolean,
      :desc => "Immediately login"
    def create(url)
      session = ClientSession.new(url, imk)

      standard_display verbose_request(url, session) {|req|
        req.create!
        unless options[:only]
          req.setkey!
          req.setlock!(identity_lock_key.unlock_pair) if identity_lock_key?
        end
        req.login! if options[:login]
        req
      }
    end
  end
end
