module SQRL
  class Cmd
    LogLevels = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN]
    class_option :verbose, :default => 'WARN', :desc => 'DEBUG, INFO, WARN'
    class_option :i, :type => :boolean, :desc => 'verbose=INFO'
    class_option :d, :type => :boolean, :desc => 'verbose=DEBUG'
    class_option :tif_base, :type => :numeric, :default => 16
    class_option :'10', :type => :boolean, :desc => 'tif_base=10'

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
  end
end
