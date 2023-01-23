require 'spec_helper'

RSpec.describe ZombieRecord::Restorable do
  context "when the record is deleted" do
    it "allows accessing a deleted has_one association" do
      book = Book.create!
      cover = Cover.create!(book: book)

      book.destroy
      book = Book.with_deleted.first

      expect(book.cover).not_to be_nil
    end

    it "allows accessing deleted belongs_to associations" do
      book = Book.create!
      chapter = book.chapters.create!

      book.destroy
      chapter = Chapter.with_deleted.first

      expect(chapter.book).to eq(book)
    end

    it "allows accessing deleted polymorphic belongs_to associations" do
      book = Book.create!
      tag = Tag.create!(name: "jelly", taggable: book)

      tag.destroy
      tag = Tag.with_deleted.first

      expect(tag.taggable).to eq(book)
    end

    it "ensures deleted associations themselves allow access to deleted records" do
      book = Book.create!
      chapter = book.chapters.create!
      book.bookmarks.create!

      book.destroy
      bookmark = Bookmark.with_deleted.first

      expect(bookmark.book.chapters).to eq([chapter])
      chapter = bookmark.book.chapters.first

      expect(chapter.book).to eq(book)
    end

    it "forwards normal method calls" do
      book = Book.create!(title: "The Odyssey")
      book.destroy
      book = Book.with_deleted.first

      expect(book.title).to eq("The Odyssey")
    end

    it "forwards to_ary" do
      book = Book.create!(title: "The Odyssey")
      book.destroy
      book = Book.with_deleted.first

      # #flatten will implicitly call #to_ary
      expect([[[book]]].flatten).to eq([book])
    end

    it "doesn't re-save duplicated record" do
      book = Book.create!(title: "The Odyssey")
      book.destroy
      book_dup = Book.with_deleted.first.save(validate: true)

      expect(Book.count).to eq(0)
      expect(Book.with_deleted.size).to eq(1)
    end
  end

  describe ".deleted" do
    it "scopes the query to only deleted records" do
      book1 = Book.create!
      book2 = Book.create!

      book1.destroy

      expect(Book.deleted).to eq([book1])
    end

    it "respects associations" do
      author = Author.create!
      book = Book.create!(author: author)
      other_book = Book.create!

      book.destroy
      other_book.destroy

      expect(author.books.deleted).to eq([book])
    end
  end

  describe "#destroy" do
    it "sets #updated_at if it is defined" do
      book = Timecop.travel(2.days.ago) { Book.create! }
      updated_at = book.updated_at

      book.destroy

      expect(book.updated_at).not_to eq(updated_at)
    end

    it "does not set #updated_at if it is not defined" do
      bookmark = Timecop.travel(2.days.ago) { Bookmark.create! }
      expect { bookmark.destroy }.to_not raise_exception
    end

    it "updates the counter cache" do
      book = Book.create!
      bookmark = book.bookmarks.create!

      expect(book.reload.bookmarks_count).to eq(1)

      bookmark.destroy!

      expect(book.reload.bookmarks_count).to eq(0)
    end
  end

  describe "#restore!" do
    let(:book) { Book.create! }
    let(:deleted_book) { Book.deleted.find(book.id) }

    it "restores the record" do
      book.destroy

      deleted_book.restore!
      expect(deleted_book.deleted_at).to be_nil
    end

    it "also restores restorable has_many associated records" do
      chapter = book.chapters.create!

      book.destroy
      deleted_book.restore!

      deleted_chapter = Chapter.with_deleted.find(chapter.id)
      expect(deleted_chapter.deleted_at).to be_nil
    end

    it "also restores restorable has_one associated records" do
      cover = book.create_cover!

      book.destroy
      deleted_book.restore!

      deleted_cover = Cover.with_deleted.find(cover.id)
      expect(deleted_cover.deleted_at).to be_nil
    end

    it "also restores restorable belongs_to associated records" do
      author = Author.create!
      book.update_attribute(:author, author)

      book.destroy
      deleted_book.restore!

      deleted_author = Author.with_deleted.find(author.id)
      expect(deleted_author.deleted_at).to be_nil
    end

    it "does not restore hard deleted associated records" do
      note = book.notes.create!

      book.destroy
      deleted_book.restore!

      expect(Note.where(id: note.id)).not_to exist
    end

    it "does not restore an association if it is not destroy dependent" do
      library = Library.create!
      book.update_attribute(:library, library)

      book.destroy
      library.destroy
      deleted_book.restore!

      library_after_deletion = Library.with_deleted.find(library.id)
      expect(library_after_deletion.deleted_at).not_to be_nil
    end

    it "fails if the object itself has been destroyed" do
      book.destroy

      expect { book.restore! }.to raise_exception(RuntimeError)
    end
  end

  describe "#deleted?" do
    let(:book) { Book.create! }

    it "returns true if the record is deleted" do
      book.destroy

      expect(book).to be_deleted
    end

    it "returns false if the record is not deleted" do
      expect(book).not_to be_deleted
    end
  end
end
