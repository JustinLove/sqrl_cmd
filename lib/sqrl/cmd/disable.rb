module SQRL
  class Cmd
    desc 'disable URL', 'Disable ordinary access to your account via SQRL'
    def disable(url)
      standard_display verbose_request(url) {|req|
        req.disable!
      }
    end
  end
end
