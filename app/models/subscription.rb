class Subscription < ActiveRecord::Base
  scope :active, ->{ where(active: true) }
  scope :inactive, ->{ where(active: false) }
  belongs_to :user
  belongs_to :show
  belongs_to :next_notification_episode, class_name: 'Episode'
  belongs_to :previous_notification_episode, class_name: 'Episode'
  has_many :notifications, dependent: :destroy
  enum subtype: { episode: 'episode', season: 'season' }

  alias_method :next_ep, :next_notification_episode
  alias_method :prev_ep, :previous_notification_episode

  before_create :set_next_notification_episode

  validates_uniqueness_of :user_id, scope: [:show_id]

  def update_next_ep
    ep = if episode?
      upeps = show.upcoming_episodes
      upeps = upeps.where(season: next_ep.season) if next_ep
      upeps.limit(episodes_interval).last
    else
      show.current_season.episodes.last if show.current_season
    end
    update(next_notification_episode: ep)
  end

  def check
    if !next_ep || subtype == 'season' || (prev_ep && next_ep.number - prev_ep.number != episodes_interval)
      update_next_ep if !next_ep || !next_ep.last_in_season?
    end
    next_ep.air_date == Date.today if next_ep
  end

  def notify
    nt = Notification.create(subscription: self, message: notification_message)
    # if nt.perform
    nt.perform
    nt.update(performed: true)
    switch_to_next_notification_episode
    # end
  end

  def switch_to_next_notification_episode
    if next_ep.air_date <= Date.today
      update(previous_notification_episode: next_ep)
      ep
      if episode?
        ep = if next_ep.last_in_season?
          show.upcoming_episodes.limit(episodes_interval).last
        else
          show.upcoming_episodes.where(season: next_ep.season).limit(episodes_interval).last
        end
      else
        ep = show.current_season.episodes.last if show.current_season
      end
      update(next_notification_episode: ep)
    end
  end

  def self.subscribe user, show_id, subtype = 'episode', episode_id = nil, active = true
    show = Show.find(show_id)
    episode = show.episodes.find(episode_id) if episode_id
    sub = user.subscriptions.where(show: show).first_or_initialize
    sub.subtype = subtype
    sub.episodes_interval = (episode ? episode.number - show.next_episode.number + 1 : 1 if sub.episode?)
    sub.next_notification_episode = sub.episode? ? (episode || show.next_episode) : (show.current_season.episodes.last if show.current_season)
    sub.previous_notification_episode = nil
    sub.active = active
    sub.save
    sub
  end

  private
  def set_next_notification_episode
    if episode?
      self.episodes_interval ||= 1
      unless next_notification_episode
        self.next_notification_episode = show.upcoming_episodes.limit(episodes_interval).last
      end
    end
  end

  def get_replacement word
    show, season, episode = next_ep.show, next_ep.season, next_ep
    case word
    when 'show_name'
      show.name(user.language)
    when 'show_name_original'
      show.name_original
    when 'episode_number'
      episode.number
    when 'season_number'
      season.number
    when 'episodes_interval'
      episodes_interval
    else
      'unknown'
    end
  end

  def notification_message
    lang = user.language || :ru
    key = episodes_interval > 1 ? 'episodes' : subtype
    nm = NotificationMessage.where(show: [show, nil], key: key).order(:show_id).first
    if nm
      msg = nm["message_#{lang}"]
      msg.scan(/%([a-z_]+)%/).flatten.uniq.each do |tr|
        msg.gsub!("%#{tr}%", get_replacement(tr).to_s) if tr.in? NotificationMessage::TEXT_REPLACEMENTS
      end
      msg
    end
  end
end
