###### Unreleased

* Don't delegate `:__id__` and `:__send__` to the deleted record object.

###### v1.8.0

* Drop upper limit on Rails, test with Rails main.
* Drop support for Rails < 6.0.
* Drop support for Ruby 2.7 & 3.0.

###### v1.7.0

* Add support for Rails 7.1
* Drop support for Rails 5.2 and 6.0

###### v1.6.0

* Drop support for Ruby 2.6
* Drop support for Rails 5.0 & 5.1
* Test against Ruby 3.2

###### v1.5.1

* Fix keyword arguments error for `method_missing`.

###### v1.5.0

* Add support for Rails 7.0
* Add support for Ruby 2.7, 3.0, & 3.1
* Drop support for Ruby 2.4 & 2.5
* Drop support for Rails 4.2

###### v1.4.3

* Drop support for Ruby 2.2 and 2.3.
* Drop support for Rails 4.1.
* Test against Rails 6.0 and 6.1.

###### v1.4.2

* Test against Rails 5.2 final.

###### v1.4.1

* Test against Rails 5.2.
* Test against Ruby 2.5.
* Don't implement `respond_to_missing?` when implementing `method_missing` or it
  won't work on Ruby 2.5.0. Truly confusing.

###### v1.4.0

* Test against Rails 5.1.

###### v1.3.2

* Implement `respond_to_missing?` when implementing `method_missing` or it
  won't work on Ruby 2.3.0.

###### v1.3.1

* Fix a `to_a` vs `records` bug for Rails 5.0.

###### v1.3.0

* Test against Rails 5.0.

###### v1.2.0

* Fix counter_cache behavior in Rails 4.2.

###### v1.1.2

* Fewer queries when soft deleting.

###### v1.1.1

* Test against Rails 4.2.

###### v1.1.0

* Add compatibility with Rails 4.1.

###### v1.0.0

* Remove compatibility with Rails 3, instead adding compatibility with
  Rails 4.0.

###### v0.4.0

* Allow accessing associated records on deleted objects, even if they themselves
  are deleted, e.g.

    # The post, comments, and category are all deleted.
    post = Post.with_deleted.find(...)
    post.comments
    post.category
