module ZombieRecord
  module Restorable
    extend ActiveSupport::Concern

    included do
      default_scope { where(deleted_at: nil) }

      define_callbacks :restore
    end

    # Override Rails' #destroy for soft-delete functionality
    # When changing to Rails 4, override #destroy_row with a one-liner instead.
    def destroy
      run_callbacks :destroy do
        destroy_associations

        if persisted?
          time = current_time_from_proper_timezone

          columns_to_update = { deleted_at: time }

          if self.class.column_names.include?("updated_at")
            columns_to_update.merge!(updated_at: time)
          end

          update_columns(columns_to_update)
        end

        @destroyed = true
        freeze
      end
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
        columns_to_update = { deleted_at: nil }

        if self.class.column_names.include?("updated_at")
          columns_to_update.merge!(updated_at: current_time_from_proper_timezone)
        end

        update_columns(columns_to_update)

        restore_associated_records!
      end
    end

    # Whether the record has been destroyed.
    #
    # Returns true if the record is deleted, false otherwise.
    def deleted?
      !deleted_at.nil?
    end

    private

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

    # Imitation of Rails 4 method
    # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/persistence.rb#L272
    def update_columns(attributes)
      self.class.unscoped.where(self.class.primary_key => id).update_all(attributes)

      attributes.each do |k, v|
        raw_write_attribute(k, v)
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
        scoped.tap {|relation| relation.default_scoped = false }
      end
    end
  end
end
