class AddEditDayFinishedAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_day_finished_at, :datetime
  end
end
