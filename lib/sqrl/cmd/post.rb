module SQRL
  class Cmd
    desc 'post URL', 'Query server status with no command'
    def post(url)
      standard_display verbose_request(url)
    end
  end
end
