module SQRL
  class Cmd
    desc 'generate [FILENAME]', 'generate a new id, and save to FILENAME'
    def generate(filename = 'sqrl.yaml')
      iuk = Key::IdentityUnlock.new
      ilk = iuk.identity_lock_key
      imk = iuk.identity_master_key
      puts "iuk: #{iuk}"
      puts "ilk: #{ilk}"
      puts "imk: #{imk}"

      store = YAML::Store.new(filename)
      store.transaction do
        store['identities'] ||= []
        store['identities'].unshift({
          'identity_unlock_key' => iuk.to_s,
          'identity_lock_key' => ilk.to_s,
          'identity_master_key' => imk.to_s,
        })
      end
    end
  end
end
