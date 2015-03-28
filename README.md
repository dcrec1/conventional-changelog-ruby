# Conventional::Changelog

Generates a CHANGELOG.md file from Git metadata, using the AngularJS commit conventions.

- [AngularJS Git Commit Message Conventions](https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/)


## Installation

    $ gem install conventional-changelog


## Usage

    $ conventional-changelog

or programatically:

```ruby
require 'conventional_changelog'
ConventionalChangelog::Generator.new.generate!
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/conventional-changelog/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
