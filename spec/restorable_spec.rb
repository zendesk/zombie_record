require 'spec_helper'

describe ZombieRecord::Restorable do
  describe ".deleted" do
    it "scopes the query to only deleted records" do
      book1 = Book.create!
      book2 = Book.create!

      book1.destroy

      Book.deleted.should == [book1]
    end

    it "respects associations" do
      author = Author.create!
      book = Book.create!(author: author)
      other_book = Book.create!

      book.destroy
      other_book.destroy

      author.books.deleted.should == [book]
    end
  end

  describe "#restore!" do
    let(:book) { Book.create! }
    let(:deleted_book) { Book.deleted.find(book.id) }

    it "restores the record" do
      book.destroy

      deleted_book.restore!
      deleted_book.deleted_at.should be_nil
    end

    it "fails if the object itself has been destroyed" do
      book.destroy

      expect { book.restore! }.to raise_exception(RuntimeError)
    end
  end
end
