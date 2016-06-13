class Subscription < ActiveRecord::Base
  default_scope { where(active: true) }
  belongs_to :user
  belongs_to :show
  belongs_to :episode
  belongs_to :next_notification_episode, class_name: 'Episode'
  belongs_to :previous_notification_episode, class_name: 'Episode'
  has_many :notifications, dependent: :destroy
  enum subtype: { episode: 'episode', season: 'season' }

  alias_method :next_ep, :next_notification_episode
  alias_method :prev_ep, :previous_notification_episode

  before_create :set_next_notification_episode
  after_save :check_show_status

  validates_uniqueness_of :user_id, scope: [:show_id]

  def update_next_ep
    ep = show.upcoming_episodes.where(season: next_ep.season).limit(episodes_interval).last
    update(next_notification_episode: ep)
  end

  def check
    if (prev_ep && next_ep.number - prev_ep.number != episodes_interval) || subtype == 'season'
      update_next_ep unless next_ep.last_in_season?
    end
    next_ep.air_date == Date.today
  end

  def notification_message lang = nil
    lang ||= :ru
    key = episodes_interval > 1 ? 'episodes' : subtype
    nm = NotificationMessage.where(show: [show, nil], key: key).order(:show_id).limit(1)
    nm["message_#{lang}"]
  end

  def notify
    nt = Notification.create(subscription: self, message: notification_message(user.language))
    if nt.perform
      nt.update(performed: true)
    end
  end

  def switch_to_next_notification_episode
    if next_ep.air_date >= Date.today
      update(previous_notification_episode: next_ep)
      ep = if next_ep.last_in_season?
        show.upcoming_episodes.limit(episodes_interval).last
      else
        show.upcoming_episodes.where(season: next_ep.season).limit(episodes_interval).last
      end
      update(next_notification_episode: ep)
    end
  end

  private
  def set_next_notification_episode
    if episode?
      episodes_interval ||= 1
      unless next_notification_episode
        self.next_notification_episode = show.upcoming_episodes.limit(episodes_interval).last
      end
    end
  end

  def check_show_status
    unless show.closed?
      if show.airing?
        show.hiatus! if !show.next_episode || show.next_episode.first?
      elsif show.hiatus?
        show.airing! if prev_ep.number == 1
      end
    end
  end
end
