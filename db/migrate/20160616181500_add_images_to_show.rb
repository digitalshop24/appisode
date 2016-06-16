class AddImagesToShow < ActiveRecord::Migration
  def change
    add_attachment :shows, :image
    add_attachment :shows, :subscription_image
  end
end
