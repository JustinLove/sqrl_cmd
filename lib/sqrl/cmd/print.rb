require "sqrl/tif"
require "httpclient"

module SQRL
  class Cmd
    private
    def verbose_request(url, session = nil)
      session ||= ClientSession.new(url, imk)
      req = QueryGenerator.new(session, url)
      req = yield req if block_given?
      req.commands << options[:command] if options[:command]
      log.info req.client_data.inspect
      log.debug req.client_string
      log.debug req.server_string
      log.debug req.to_hash.inspect
      log.info "POST #{req.post_path}\n\n"
      log.info req.post_body
      res = HTTPClient.new.post(req.post_path, req.post_body)
      log.info "Response: #{res.status}"
      log.info res.body

      parsed = ResponseParser.new(session, res.body)
      parsed.tif_base = tif_base
      log.info parsed.params.inspect
      parsed
    rescue Errno::ECONNREFUSED => e
      log.error e.message
      ResponseParser.new(session, {'exception' => e})
    end

    def print_tif(tif)
      print_table SQRL::TIF.map {|bit, flag|
        if (tif & bit) != 0
          [bit.to_s(16), flag.to_s.upcase]
        else
          ['  ', flag]
        end
      }
    end

    def standard_display(parsed)
      print_tif(parsed.tif)
      puts "#{parsed.server_friendly_name} -- #{parsed.ask}"
    end
  end
end
