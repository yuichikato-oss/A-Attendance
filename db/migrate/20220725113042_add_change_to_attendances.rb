class AddChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change, :boolean, default: false
  end
end
