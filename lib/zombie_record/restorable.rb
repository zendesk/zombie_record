module ZombieRecord
  module Restorable
    extend ActiveSupport::Concern

    included do
      default_scope { where(deleted_at: nil) }
    end

    # Override Rails' #destroy for soft-delete functionality
    # When changing to Rails 4, override #destroy_row with a one-liner instead.
    def destroy
      run_callbacks :destroy do
        destroy_associations

        if persisted?
          time = current_time_from_proper_timezone
          update_column(:updated_at, time)
          update_column(:deleted_at, time)
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

      update_column(:deleted_at, nil)

      restore_associated_records!
    end

    private

    def restore_associated_records!
      self.class.reflect_on_all_associations.each do |association|
        if association.options[:dependent] == :destroy
          records = Array.wrap(public_send(association.name).deleted)

          records.each do |record|
            record.restore!
          end
        end
      end
    end

    module ClassMethods

      # Scopes the relation to only include deleted records.
      #
      # Returns an ActiveRecord::Relation.
      def deleted
        with_deleted.where("deleted_at IS NOT NULL")
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
