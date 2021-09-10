require "active_support"
require "zombie_record/version"

module ZombieRecord
end

require "zombie_record/restorable"

module ActiveRecord
  module Persistence
    alias_method :zombie_record_alias_destroy_row, :destroy_row

    # Maybe override Rails' #destroy_row for soft-delete functionality
    def destroy_row
      if self.class.include?(ZombieRecord::Restorable)
        time = current_time_from_proper_timezone

        update_params = { deleted_at: time }
        if self.class.column_names.include?("updated_at")
          update_params[:updated_at] = time
        end

        update_columns(update_params) ? 1 : 0
      else
        zombie_record_alias_destroy_row
      end
    end
  end
end
