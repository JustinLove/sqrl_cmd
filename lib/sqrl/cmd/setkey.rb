module SQRL
  class Cmd
    desc 'setkey [URL]', 'Issue setkey command'
    def setkey(url)
      standard_display verbose_request(url) {|req| req.setkey!}
    end
  end
end
