module SQRL
  class Cmd
    desc 'ident URL', 'Login/create assoction'
    long_desc <<-LONGDESC
      loops=1: The first request to the server includes the ident command

      loops=2: Send a only query, and then prompt the user whether to login using the server friendly name.
    LONGDESC
    option :loops, :type => :numeric, :default => 2,
      :desc => "1: direct, 2: check server first"
    def ident(url)
      session = ClientSession.new(url, imk)
      setlock = false

      if options[:loops] >= 2
        parsed = verbose_request(url, session) {|req| req.query!}
        print_tif(parsed.tif)
        setlock = !parsed.id_match?
        return unless yes?("log in to '#{parsed.server_friendly_name}'?")
      end

      standard_display verbose_request(url, session) {|req|
        req.ident!
        if setlock && identity_lock_key?
          req.setlock(identity_lock_key.unlock_pair)
        end
        req
      }
    end
  end
end
