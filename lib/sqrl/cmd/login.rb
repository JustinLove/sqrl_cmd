module SQRL
  class Cmd
    desc 'login URL', 'Attempt login'
    long_desc <<-LONGDESC
      loops=1: The first request to the server includes the login command

      loops=2: Send a request with no command, and then prompt the user whether to login using the server friendly name.
    LONGDESC
    option :loops, :type => :numeric, :default => 2,
      :desc => "1: direct, 2: check server first"
    def login(url)
      session = ClientSession.new(url, imk)

      if options[:loops] >= 2
        parsed = verbose_request(url, session)
        print_tif(parsed.tif)
        unless parsed.id_match?
          puts "Abort, ID not known"
          return
        end
        return unless yes?("log in to '#{parsed.server_friendly_name}'?")
      end

      standard_display verbose_request(url, session) {|req| req.login!}
    end
  end
end
