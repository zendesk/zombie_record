require 'bundler/setup'
require 'active_record'
require 'timecop'
require 'byebug'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'zombie_record'

class Book < ActiveRecord::Base
  include ZombieRecord::Restorable

  belongs_to :library
  belongs_to :author, dependent: :destroy
  has_one :cover, dependent: :destroy

  has_many :chapters, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :notes, dependent: :destroy
end

class Chapter < ActiveRecord::Base
  include ZombieRecord::Restorable

  belongs_to :book
end

class Bookmark < ActiveRecord::Base
  include ZombieRecord::Restorable

  belongs_to :book, counter_cache: true
end

class Note < ActiveRecord::Base
  belongs_to :book
end

class Author < ActiveRecord::Base
  include ZombieRecord::Restorable

  has_many :books
end

class Tag < ActiveRecord::Base
  include ZombieRecord::Restorable

  belongs_to :taggable, polymorphic: true, dependent: :destroy
end

class Cover < ActiveRecord::Base
  include ZombieRecord::Restorable

  belongs_to :book
end


class Library < ActiveRecord::Base
  include ZombieRecord::Restorable

  has_many :book
end

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  config.before :suite do
    ActiveRecord::Base.establish_connection(
      adapter: "mysql2",
      username: "root",
      host: "127.0.0.1",
      port: 3306,
      password: ""
    )

    ActiveRecord::Base.connection.create_database("zombie_record")
    ActiveRecord::Base.connection.execute("use zombie_record;")

    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :books do |t|
        t.integer :author_id
        t.integer :library_id
        t.integer :bookmarks_count
        t.timestamps null: false
        t.string :title
        t.timestamp :deleted_at
      end

      create_table :chapters do |t|
        t.integer :book_id
        t.timestamps null: false
        t.timestamp :deleted_at
      end

      create_table :bookmarks do |t|
        t.integer :book_id
        t.timestamp :created_at
        t.timestamp :deleted_at
      end

      create_table :notes do |t|
        t.integer :book_id
        t.timestamps null: false
      end

      create_table :tags do |t|
        t.string :name
        t.string :taggable_type
        t.integer :taggable_id
        t.timestamp :deleted_at
      end

      create_table :covers do |t|
        t.integer :book_id
        t.timestamps null: false
        t.timestamp :deleted_at
      end

      create_table :authors do |t|
        t.timestamps null: false
        t.timestamp :deleted_at
      end

      create_table :libraries do |t|
        t.timestamps null: false
        t.timestamp :deleted_at
      end
    end
  end

  config.after :suite do
    ActiveRecord::Base.connection.drop_database("zombie_record") rescue nil
  end
end
