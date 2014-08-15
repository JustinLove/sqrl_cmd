# SqrlCmd

Test-and-debug focused command line client for the [SQRL protocol](https://www.grc.com/sqrl/sqrl.htm)

## Installation

Add this line to your application's Gemfile:

    gem 'sqrl_cmd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sqrl_cmd

## Usage

$ sqrlcmd
Commands:
  sqrlcmd create [URL]    # Create a new account on the system
  sqrlcmd help [COMMAND]  # Describe available commands or one specific command
  sqrlcmd login [URL]     # Attempt login
  sqrlcmd logout [URL]    # Issue logout command
  sqrlcmd post [URL]      # Query server status with no command
  sqrlcmd setkey [URL]    # Issue setkey command
  sqrlcmd setlock [URL]   # Send the server and verify unlock keys
  sqrlcmd sign [URL]      # Print the signed request

Options:
  [--verbose=VERBOSE]  # DEBUG, INFO, WARN
                       # Default: WARN
  [-i], [--no-i]       # verbose=INFO
  [-d], [--no-d]       # verbose=DEBUG
  [--tif-base=N]       
                       # Default: 16
  [--10], [--no-10]    # tif_base=10
  [--imk=IMK]          # Identity Master Key
  [--iuk=IUK]          # Identity Unlock Key

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
