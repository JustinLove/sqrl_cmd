module SQRL
  class Cmd
    desc 'query URL', 'Query server status'
    def query(url)
      standard_display verbose_request(url) {|req| req.query!}
    end
  end
end
