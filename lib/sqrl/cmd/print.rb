require "sqrl/tif"
require "sqrl/cmd/version"
require "httpclient"

module SQRL
  class Cmd
    private

    def create_session(url)
      url = upgrade_url(url)
      ClientSession.new(url, [imk, pimk].compact)
    end

    SqrlHeaders = {'Content-Type' => 'application/x-www-form-urlencoded'}
    SqrlRequest = {
      :agent_name => "SQRL/1 SQRL::Cmd/#{SqrlCmd::VERSION}",
      :default_header => SqrlHeaders,
    }

    def verbose_request(server_string, session = nil, retries = 1)
      session ||= create_session(server_string)
      req = QueryGenerator.new(session, session.server_string)
      req.opt(*opt)
      req = yield req if block_given?
      log.info req.client_data.inspect
      log.debug req.client_string
      log.debug req.server_string
      log.debug req.to_hash.inspect
      log.info "POST #{req.post_path}\n\n"
      log.info req.post_body
      res = HTTPClient.new(SqrlRequest).post(req.post_path, req.post_body)
      log.info "Response: #{res.status}"
      log.info res.body

      parsed = ResponseParser.new(session, res.body)
      parsed.tif_base = tif_base
      log.info parsed.params.inspect

      if parsed.transient_error? && retries > 0
        standard_display(parsed) if log.level <= Logger::INFO
        puts "Transient error, retrying"
        verbose_request(session.server_string, session, retries - 1)
      else
        parsed
      end
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
      puts "#{parsed.server_friendly_name} -- #{parsed.ask.message}"
    end

    def open_browser(url)
      case RbConfig::CONFIG['host_os']
      when /mswin|mingw|cygwin/; system "start #{url}"
      when /darwin/;             system "open #{url}"
      when /linux|bsd/;          system "xdg-open #{url}"
      else puts url
      end
    end
  end
end
