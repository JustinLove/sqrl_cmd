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
    class_option :pimk, :type => :string, :desc => 'Previous Identity Master Key'
    class_option :iuk, :type => :string, :desc => 'Identity Unlock Key'
    class_option :piuk, :type => :string, :desc => 'Previous Identity Unlock Key'
    class_option :ilk, :type => :string, :desc => 'Identity Lock Key'

    class_option :keyfile, :type => :string, :default => 'sqrl.yaml',
      :aliases => :f,
      :desc => 'YAML file with key defintions'

    class_option :suk, :type => :boolean,
      :desc => 'request server unlock key in response'
    class_option :opt, :type => :array,
      :aliases => :o, :default => [],
      :desc => 'free-form sqrl options'

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
      options[:iuk] || identities.first['identity_unlock_key']
    end

    def identity_unlock_key?
      !!raw_iuk
    end

    def identity_unlock_key
      @iuk ||= if string = raw_iuk
        Key::IdentityUnlock.new(parse_key(string))
      else
        missing_key('Identity Unlock', 'iuk')
      end
    end

    def raw_piuk
      return options[:piuk] if options[:piuk]
      if identities[1]
        identities[1]['identity_unlock_key']
      end
    end

    def previous_identity_unlock_key?
      !!raw_piuk
    end

    def previous_identity_unlock_key
      @piuk ||= if string = raw_piuk
        Key::IdentityUnlock.new(parse_key(string))
      else
        missing_key('Previous Identity Unlock', 'piuk')
      end
    end

    def raw_imk
      options[:imk] || identities.first['identity_master_key']
    end

    def imk?
      !!raw_imk || identity_unlock_key?
    end

    def imk
      @imk ||= if string = raw_imk
        Key::IdentityMaster.new(parse_key(string))
      elsif identity_unlock_key?
        identity_unlock_key.identity_master_key
      else
        missing_key('Identity Master', 'imk')
      end
    end

    def raw_pimk
      return options[:pimk] if options[:pimk]
      if identities[1]
        identities[1]['identity_master_key']
      end
    end

    def pimk?
      !!raw_pimk
    end

    def pimk
      @pimk ||= if string = raw_pimk
        Key::IdentityMaster.new(parse_key(string))
      end
    end

    def raw_ilk
      options[:ilk] || identities.first['identity_lock_key']
    end

    def identity_lock_key?
      !!raw_ilk || identity_unlock_key?
    end

    def identity_lock_key
      @ilk ||= if string = raw_ilk
        Key::IdentityLock.new(parse_key(string))
      elsif identity_unlock_key?
        identity_unlock_key.identity_lock_key
      else
        missing_key('Identity Lock', 'ilk')
      end
    end

    def opt
      options[:opt] | (options[:suk] ? ['suk'] : [])
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
      @store ||= YAML::Store.new(options[:keyfile])
    end

    def identities
      store.transaction {
        (store['identities'] && store['identities']) || [Hash.new({})]
      }
    end

    def missing_key(name, option)
      log.fatal "#{name} Key not available.  Provide --#{option} or use `sqrlcmd generate` to create a file."
      exit
    end
  end
end
