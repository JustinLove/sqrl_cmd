module SQRL
  class Cmd
    desc 'keys', 'print the effective keys given all options'
    def keys
      puts "Loaded keys:"
      puts "iuk: #{identity_unlock_key}" if identity_unlock_key?
      puts "ilk: #{identity_lock_key}" if identity_lock_key?
      puts "imk: #{imk}" if imk?
      puts "pimk: #{pimk}" if pimk?
    end
  end
end
