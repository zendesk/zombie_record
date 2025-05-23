# Zombie Record

Allows restoring your Active Records from the dead!

[![Build Status](https://github.com/zendesk/zombie_record/workflows/CI/badge.svg)](https://github.com/zendesk/zombie_record/actions?query=workflow%3ACI)

## Installation

Add this line to your application's Gemfile:

    gem 'zombie_record'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zombie_record

## Usage

Simply include the `ZombieRecord::Restorable` in your model class:

```ruby
class Book < ActiveRecord::Base
  include ZombieRecord::Restorable
end
```

Zombie Record assumes the model's table has a `deleted_at` column with the `timestamp` type.

You can now delete and restore Book records:

```ruby
book = Book.find(42)
book.destroy

Book.find(42) # raises ActiveRecord::RecordNotFound.

book = Book.deleted.find(42)
book.restore!

Book.find(42) # returns the Book record.
```

## Compatibility

Zombie Record only works with Active Record >= 4. For Active Record 3 compatibility, check out the activerecord-3 branch of this gem.

### Releasing a new version
A new version is published to RubyGems.org every time a change to `version.rb` is pushed to the `main` branch.
In short, follow these steps:
1. Update `version.rb`,
2. update version in all `Gemfile.lock` files,
3. merge this change into `main`, and
4. look at [the action](https://github.com/zendesk/zombie_record/actions/workflows/publish.yml) for output.

To create a pre-release from a non-main branch:
1. change the version in `version.rb` to something like `1.2.0.pre.1` or `2.0.0.beta.2`,
2. push this change to your branch,
3. go to [Actions → “Publish to RubyGems.org” on GitHub](https://github.com/zendesk/zombie_record/actions/workflows/publish.yml),
4. click the “Run workflow” button,
5. pick your branch from a dropdown.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
