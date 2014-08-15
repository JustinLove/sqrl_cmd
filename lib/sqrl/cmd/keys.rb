require "sqrl/key/identity_master"
require "sqrl/key/identity_unlock"

module SQRL
  class Cmd
    private
    def imk
      Key::IdentityMaster.new('x'.b*32)
    end

    def identity_unlock_key
      Key::IdentityUnlock.new('x'.b*32)
    end

    def identity_lock_key
      @ilk ||= identity_unlock_key.identity_lock_key
    end
  end
end
