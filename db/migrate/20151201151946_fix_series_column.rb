class FixSeriesColumn < ActiveRecord::Migration
  def change
    change_column :series, :title, :text
  end
end
