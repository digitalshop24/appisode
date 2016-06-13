class ChangeNameColumnsInShow < ActiveRecord::Migration
  def change
  	rename_column :shows, :name, :name_original
  	rename_column :shows, :russian_name, :name_ru
  	add_column :shows, :name_en, :string
  end
end
