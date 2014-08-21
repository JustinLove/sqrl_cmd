module SQRL
  class Cmd
    desc 'keys', 'print the effective keys given all options'
    def keys
      puts "iuk: #{identity_unlock_key}"
      puts "ilk: #{identity_lock_key}"
      puts "imk: #{imk}"
    end
  end
end
