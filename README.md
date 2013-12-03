# Zombie Record

Allows restoring your Active Records from the dead!

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
