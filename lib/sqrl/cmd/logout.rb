module SQRL
  class Cmd
    desc 'logout [URL]', 'Issue logout command'
    option :logoff, :type => :boolean
    def logout(url)
      standard_display verbose_request(url) {|req|
        if options[:logoff]
          req.logoff!
        else
          req.logout!
        end
      }
    end
  end
end
