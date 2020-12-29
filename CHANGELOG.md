###### Unreleased

* Drop support for Ruby 2.2 and 2.3.

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
