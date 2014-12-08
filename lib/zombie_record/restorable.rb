module ZombieRecord
  module Restorable
    extend ActiveSupport::Concern

    included do
      default_scope { where(deleted_at: nil) }

      define_callbacks :restore
    end

    # Restores a destroyed record.
    #
    # Returns nothing.
    def restore!
      if frozen?
        raise "cannot restore an object that has been destroyed directly; " <<
              "please make sure to load it from the database again."
      end

      run_callbacks :restore do
        update_column(:deleted_at, nil)

        restore_associated_records!
      end
    end

    # Whether the record has been destroyed.
    #
    # Returns true if the record is deleted, false otherwise.
    def deleted?
      !deleted_at.nil?
    end

    # Allows accessing deleted associations from the record.
    #
    # Example
    #
    #   book = Book.first.with_deleted_associations
    #
    #   # Even deleted chapters are returned!
    #   book.chapters #=> [...]
    #
    # Returns a wrapped ActiveRecord::Base object.
    def with_deleted_associations
      if deleted?
        WithDeletedAssociations.new(self)
      else
        self
      end
    end

    private

    # Override Rails' #destroy_row for soft-delete functionality
    def destroy_row
      time = current_time_from_proper_timezone
      update_column(:deleted_at, time)

      if self.class.column_names.include?("updated_at")
        update_column(:updated_at, time)
      end
    end

    def restore_associated_records!
      self.class.reflect_on_all_associations.each do |association|
        # Only restore associations that are automatically destroyed alongside
        # the record.
        next unless association.options[:dependent] == :destroy

        # Don't try to restore models that are not restorable.
        next unless association.klass.ancestors.include?(Restorable)

        records = deleted_records_for_association(association)

        records.each do |record|
          record.restore!
        end
      end
    end

    def deleted_records_for_association(association)
      if association.macro == :has_one
        foreign_key = association.foreign_key
        association.klass.deleted.where(foreign_key => id)
      elsif association.macro == :has_many
        public_send(association.name).deleted
      elsif association.macro == :belongs_to
        associated_id = public_send(association.foreign_key)
        return [] unless associated_id.present?
        association.klass.deleted.where(:id => associated_id)
      else
        raise "association type #{association.macro} not supported"
      end
    end

    # Wraps a deleted record and makes sure that any associated record is
    # available even if it is deleted. This is done by intercepting the method
    # calls, checking if the method is an association access, and then ensuring
    # that deleted records are included in the resulting query.
    class WithDeletedAssociations < BasicObject
      def initialize(record)
        @record = record
      end

      def method_missing(name, *args, &block)
        delegate_to_record(name) { @record.public_send(name, *args, &block) }
      end

      # We want *all* methods to be delegated.
      BasicObject.instance_methods.each do |name|
        define_method(name) do |*args, &block|
          @record.public_send(name, *args, &block)
        end
      end

      private

      def delegate_to_record(name, &block)
        if reflection = reflect_on(name)
          with_deleted_associations(reflection, &block)
        else
          block.call
        end
      end

      def reflect_on(name)
        reflection = @record.class.reflect_on_association(name)

        if reflection && restorable_reflection?(reflection)
          reflection
        end
      end

      def associated_record_class(reflection)
        # Polymorphic associations don't have an easy way to access the class,
        # so we'll have to do it ourselves.
        if reflection.options[:polymorphic]
          @record.public_send(reflection.foreign_type).constantize
        else
          reflection.klass
        end
      end

      def restorable_reflection?(reflection)
        associated_record_class(reflection).ancestors.include?(Restorable)
      end

      def with_deleted_associations(reflection, &block)
        case reflection.macro
        when :has_one, :belongs_to
          associated_record_class(reflection).unscoped(&block).with_deleted_associations
        when :has_many
          block.call.with_deleted
        else
          raise "invalid macro #{reflection.macro.inspect}"
        end
      end
    end

    module WithDeletedAssociationsWrapper
      def to_a
        super.map(&:with_deleted_associations)
      end
    end

    module ClassMethods

      # Scopes the relation to only include deleted records.
      #
      # Returns an ActiveRecord::Relation.
      def deleted
        with_deleted.where("#{quoted_table_name}.deleted_at IS NOT NULL")
      end

      # Scopes the relation to include both active and deleted records.
      #
      # Returns an ActiveRecord::Relation.
      def with_deleted
        if ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR == 0
          all.
            tap {|relation| relation.default_scoped = false }.
            extending(WithDeletedAssociationsWrapper)
        else
          all.
            unscope(where: :deleted_at).
            extending(WithDeletedAssociationsWrapper)
        end
      end
    end
  end
end
