require 'sqrl/key/unlock_request_signing'

module SQRL
  class Cmd
    desc 'ident URL', 'Login/create assoction'
    long_desc <<-LONGDESC
      loops=1: The first request to the server includes the ident command

      loops=2: Send a only query, and then prompt the user whether to login using the server friendly name.
    LONGDESC
    option :loops, :type => :numeric, :default => 2,
      :desc => "1: direct, 2: check server first"
    option :setlock, :type => :boolean, :default => false,
      :desc => "Force sending suk/vuk on existing identity"
    def ident(url)
      session = create_session(url)
      setlock = options[:setlock]
      id_match = false
      previous_id_match = false
      suk = nil

      if options[:loops] >= 2
        parsed = verbose_request(session.server_string, session) {|req| req.query!}
        print_tif(parsed.tif)
        puts parsed.ask.message if parsed.ask?
        setlock ||= !(parsed.id_match? || parsed.previous_id_match?)
        id_match = parsed.id_match?
        previous_id_match = parsed.previous_id_match?
        suk = Key::ServerUnlock.new(parsed.suk) if parsed.suk?
        if parsed.sqrl_disabled? ||
           parsed.function_not_supported? ||
           parsed.transient_error? ||
           parsed.command_failed? ||
           parsed.client_failure? ||
           parsed.bad_association_id?
          return
        end
        return unless yes?("log in to '#{parsed.server_friendly_name}'?")
      end

      parsed = verbose_request(session.server_string, session) {|req|
        req.ident!
        if id_match && suk && identity_unlock_key?
          ursk = Key::UnlockRequestSigning.new(suk, identity_unlock_key)
          req.unlock(ursk)
        elsif previous_id_match && suk && previous_identity_unlock_key?
          ursk = Key::UnlockRequestSigning.new(suk, previous_identity_unlock_key)
          req.unlock(ursk)
        end
        if setlock && identity_lock_key?
          req.setlock(identity_lock_key.unlock_pair)
        end
        req
      }

      standard_display parsed
      if parsed.url?
        open_browser(parsed.url)
      end
    end
  end
end
