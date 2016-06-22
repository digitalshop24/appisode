class AddBannerToShow < ActiveRecord::Migration
  def change
    add_column :shows, :banner, :string
  end
end
