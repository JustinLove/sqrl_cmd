require "sqrl/tif"
require "sqrl/cmd/version"
require "httpclient"

module SQRL
  class Cmd
    private

    def create_session(url)
      url = upgrade_url(url)
      session = ClientSession.new(url, [imk, pimk].compact)
      puts "SFN: \"#{session.server_friendly_name}\"\n\n"
      session
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
      log.info format_params(req.client_data, 'Client Data')
      log.debug data_field("Client String", req.client_string)
      log.debug format_params(req.to_hash, 'Query')

      log.info headline('-', 'Request')
      log.info "POST #{req.post_path}"
      log.debug req.post_body
      log.debug ""
      h = HTTPClient.new(SqrlRequest)
      h.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE unless verify_cert?
      res = h.post(req.post_path, req.post_body)
      log.info "Response: #{res.status}"
      log.debug res.body
      log.info headline('-')
      log.info ""

      parsed = ResponseParser.new(res.body).update_session(session)
      parsed.tif_base = tif_base
      log.info format_params(parsed.params, 'Response')

      if parsed.transient_error? && retries > 0
        standard_display(parsed) if log.level <= Logger::INFO
        puts "Transient error, retrying"
        verbose_request(session.server_string, session, retries - 1)
      else
        parsed
      end
    rescue Errno::ECONNREFUSED => e
      log.error e.message
      session.server_string = server_string
      ResponseParser.new({'exception' => e})
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
      puts [parsed.ask.message, parsed.params['sfn']].compact.join(' -- ')
    end

    def open_browser(url)
      case RbConfig::CONFIG['host_os']
      when /mswin|mingw|cygwin/; system "start #{url}"
      when /darwin/;             system "open #{url}"
      when /linux|bsd/;          system "xdg-open #{url}"
      else puts url
      end
    end

    def headline(h = '-', s = nil)
      if s
        l = 76 - s.length
        [h*(l/2), s, h*((l+1)/2)].join(' ')
      else 
        h*78
      end
    end

    def data_field(key, value)
      "%10s : %s" % [key, value]
    end

    def format_params(params, title = nil)
      [
        headline('-', title),
        params.map {|key, value|
          data_field(key, value)
        },
        headline('-'),
        "",
      ].flatten.join("\n")
    end
  end
end
