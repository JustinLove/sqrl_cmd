require "sqrl/key/identity_master"
require "sqrl/key/identity_unlock"
require "sqrl/base64"
require "yaml/store"

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

    def raw_iuk
      options[:iuk] || store.transaction {store['identity_unlock_key']}
    end

    def identity_unlock_key
      @iuk ||= if string = raw_iuk
        Key::IdentityUnlock.new(parse_key(string))
      else
        log.error "Identity Unlock Key was requested but none was found"
        Key::IdentityUnlock.new("\0".b*32)
      end
    end

    def raw_imk
      options[:imk] || store.transaction {store['identity_master_key']}
    end

    def imk
      @imk ||= if string = raw_imk
        Key::IdentityMaster.new(parse_key(string))
      elsif raw_iuk
        identity_unlock_key.identity_master_key
      else
        log.error "Identity Master Key was requested but none was found"
        Key::IdentityMaster.new("\0".b*32)
      end
    end

    def raw_ilk
      options[:ilk] || store.transaction {store['identity_lock_key']}
    end

    def identity_lock_key
      @ilk ||= if string = raw_ilk
        Key::IdentityLock.new(parse_key(string))
      elsif raw_iuk
        identity_unlock_key.identity_lock_key
      else
        log.error "Identity Lock Key was requested but none was found"
        Key::IdentityLock.new("\0".b*32)
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

    def store
      @store ||= YAML::Store.new('sqrl.yaml')
    end
  end
end
