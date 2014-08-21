module SQRL
  class Cmd
    desc 'generate', 'generate a new id'
    def generate
      iuk = Key::IdentityUnlock.new
      ilk = iuk.identity_lock_key
      imk = iuk.identity_master_key
      puts "iuk: #{iuk}"
      puts "ilk: #{ilk}"
      puts "imk: #{imk}"

      store.transaction do
        store['identity_unlock_key'] = iuk.to_s
        store['identity_lock_key'] = ilk.to_s
        store['identity_master_key'] = imk.to_s
      end
    end
  end
end
