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
  sqrlcmd disable URL          # Disable ordinary access to your account via ...
  sqrlcmd enable URL           # Clear disabled status, requires unlock keys
  sqrlcmd generate [FILENAME]  # generate a new id, and save to FILENAME
  sqrlcmd help [COMMAND]       # Describe available commands or one specific ...
  sqrlcmd ident URL            # Login/create assoction
  sqrlcmd keys                 # print the effective keys given all options
  sqrlcmd query URL            # Query server status
  sqrlcmd remove URL           # Remove SQRL association, requires unlock keys
  sqrlcmd scan URL             # scan the url for sqrl urls
  sqrlcmd sign URL             # Print the signed request

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
      [--ilk=ILK]          # Identity Lock Key
  f, [--keyfile=KEYFILE]   # YAML file with key defintions
                           # Default: sqrl.yaml

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
