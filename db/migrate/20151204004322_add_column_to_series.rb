class AddColumnToSeries < ActiveRecord::Migration
  def change
    add_column :series, :full_date, :text
    add_column :series, :second, :text
    add_column :series, :third, :text
  end
end
