class NotificationMessage < ActiveRecord::Base
  TEXT_REPLACEMENTS = %w(show_name show_name_original episode_number season_number episodes_interval)
  belongs_to :show
end
