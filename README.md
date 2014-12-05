# Zombie Record

Allows restoring your Active Records from the dead!

[![Build Status](https://travis-ci.org/zendesk/zombie_record.svg?branch=master)](https://travis-ci.org/zendesk/zombie_record)

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

Zombie Record only works with Active Record 4. For Active Record 3 compatibility, check out the activerecord-3 branch of this gem.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
