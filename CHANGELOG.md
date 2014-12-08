###### Unreleased

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
