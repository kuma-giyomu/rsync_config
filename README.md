# RsyncConfig

This is a little utility gem to help manage the rsyncd config files on GNU/Linux systems.
It is still in infancy but is usable as is.

[![Code Climate](https://codeclimate.com/github/kuma-giyomu/rsync_config.png)](https://codeclimate.com/github/kuma-giyomu/rsync_config)

## Installation

Add this line to your application's Gemfile:

    gem 'rsync_config'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rsync_config

## Usage

You can load a config file using `RsyncConfig::load_config <file_path>` or create a config from scratch with `RsyncConfig::Config.new`.
Alternatively, you can use `RsyncConfig::parse <content>` if you prefer to provide the input from a random source.

### Properties

The `RsyncConfig::Config` instance provides access to properties via the `#[]` and `#[]=` methods. So for instance 

    config = RsyncConfig::Config.new
    config['uid'] = 'alice' # setter
    puts config['uid']      # getter

Note that the class accepts symbols as alternative `config[:uid]` is valid too.
But I felt it was best to keep as strings for the config options with spaces such as `secrets file`.

### Modules

The `RsyncConfig::Config` instance provides access to modules via the `#module` method

    config = RsyncConfig::Config.new
    foo_module = config.module :foo
    bar_module = config.module 'bar'

Here again, symbols are converted to strings (rsync allows modules with spaces and whatnot)

Properties can be assigned to modules in the same way they are added to the `RsyncConfig::Config` object.

    foo_module['uid'] = 'alice'

`RsyncConfig::Module` instances do not have modules themselves.

### Users

Both `RsyncConfig::Config` and `RsyncConfig::Module` instances can define a list of users that have access to the modules.
They are defined using the `#users` hash accessor method.
Additionally a test method `#user?` can be used to probe for a give user's existence.

    config = RsyncConfig::Config.new
    config.users = {'alice' => 'wonder'}
    puts config.user?('alice') # true
    config.users['bob'] = 'march'

### Writing to disk

Use `RsyncConfig::Config#write_to <main_output_file>`.
The gem assumes that you have write permissions on the file and a `RuntimeError` will be raised otherwise.
This method will automatically try to write the secrets files when defined.

For a raw String output, just call `RsyncConfig::Config#to_config_file` instead.
Note that this method will not return the content of the secrets file (not sure if this will be useful).

### Limitations

- currently the gem does not process the directives `&include` and `&merge`.
- the values for the properties are not checked/validated in any way.
- the way secrets files are handled is simplistic since the files will be written/read multiple times if specified more than once

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
