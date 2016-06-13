class AddStatusToShow < ActiveRecord::Migration
  def up
    add_column :shows, :status, :show_status
    Show.where(in_production: false).update_all(status: 'closed')
    Show.where(in_production: true).each do |show|
      status = (show.next_episode && show.next_episode.number != 1) ? 'airing' : 'hiatus'
      show.update(status: status)
    end
    remove_column :shows, :in_production
  end
  def down
    add_column :shows, :in_production, :boolean
    Show.where(status: %w(airing hiatus)).update_all(in_production: true)
    Show.where(status: %w(closed)).update_all(in_production: false)
    remove_column :shows, :status
  end
end