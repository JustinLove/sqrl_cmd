require "sqrl/key/identity_master"
require "sqrl/key/identity_unlock"
require "sqrl/base64"

module SQRL
  class Cmd
    LogLevels = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN]
    class_option :verbose, :default => 'WARN', :desc => 'DEBUG, INFO, WARN'
    class_option :i, :type => :boolean, :desc => 'verbose=INFO'
    class_option :d, :type => :boolean, :desc => 'verbose=DEBUG'

    class_option :tif_base, :type => :numeric, :default => 16
    class_option :'10', :type => :boolean, :desc => 'tif_base=10'

    class_option :imk, :type => :string, :desc => 'Identity Master Key'
    class_option :iuk, :type => :string, :desc => 'Identity Unlock Key'
    class_option :ilk, :type => :string, :desc => 'Identity Lock Key'

    private
    def verbose
      d = options[:d] && 'DEBUG'
      i = options[:i] && 'INFO'
      v = options[:verbose].to_s.upcase
      ([d, i, v, "WARN"] & LogLevels).compact.first
    end

    def tif_base
      (options[:'10'] && 10) || options[:tif_base]
    end

    def imk
      Key::IdentityMaster.new(parse_key(options[:imk] || 'x'.b*32))
    end

    def identity_unlock_key
      Key::IdentityUnlock.new(parse_key(options[:iuk] || 'x'.b*32))
    end

    def identity_lock_key
      @ilk ||= if options[:ilk]
        Key::IdentityLock.new(parse_key(options[:ilk]))
      else
        identity_unlock_key.identity_lock_key
      end
    end

    def parse_key(key)
      x = case key.length
      when 32; key.b
      when 43; SQRL::Base64.decode(key)
      when 44; ::Base64.decode64(key)
      when 64; [key].pack('H*')
      else
        log.fatal "Unknown key format provided '#{key}', #{key.length} characters"
        exit
      end
    end
  end
end
