###### Unreleased

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
