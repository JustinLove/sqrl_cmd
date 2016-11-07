require "sqrl/cmd/version"
require "httpclient"

module SQRL
  class Cmd
    desc 'scan URL', 'scan the url for sqrl urls'
    def scan(url)
      puts upgrade_url(url)
    end

    private
    ScanRequest = {
      :agent_name => "SQRL::Cmd/#{SqrlCmd::VERSION}",
    }
    def upgrade_url(url)
      return url unless url.start_with?('http')
      log.info "GET #{url}"
      h = HTTPClient.new(ScanRequest)
      h.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE unless verify_cert?
      res = h.get(url)
      log.info "Response: #{res.status}"
      matches = res.body.match(/"(s?qrl:\/\/[^"]+)"/m)
      if matches
        if matches.length > 2
          puts "multiple matches"
          (1...matches.length).to_a.each do |i|
            puts matches[i]
          end
        else
          log.info matches[1]
        end
        return matches[1].gsub('&amp;', '&')
      else
        return url
      end
    end
  end
end
