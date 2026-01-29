class SchedulingRule < ApplicationRecord
  belongs_to :user, inverse_of: :scheduling_rules
  belongs_to :diary, inverse_of: :scheduling_rule
  has_many :schedulings, inverse_of: :scheduling_rule, dependent: :destroy

  validates :start_time, :end_time, :week_days, :session_duration_minutes, presence: true
  validates :session_duration_minutes, numericality: { only_integer: true, greater_than: 0 }

  before_validation :queue_duration_change, on: :update

  validate :end_date_not_before_start_date
  validate :end_time_after_start_time

  validate :session_duration_multiple_of_15
  validate :session_duration_next_multiple_of_15

  def effective_duration_minutes(at: Time.current)
    return session_duration_minutes if session_duration_minutes_next.blank? || session_duration_effective_at.blank?

    at >= session_duration_effective_at ? session_duration_minutes_next : session_duration_minutes
  end

  private

  def end_date_not_before_start_date
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be equal or after start_date") if end_date < start_date
  end

  def session_duration_multiple_of_15
    return if session_duration_minutes.blank?
    return if (session_duration_minutes % 15).zero?

    errors.add(:session_duration_minutes, "must be a multiple of 15 minutes")
  end

  def session_duration_next_multiple_of_15
    return if session_duration_minutes_next.blank?
    return if (session_duration_minutes_next % 15).zero?

    errors.add(:session_duration_minutes_next, "must be a multiple of 15 minutes")
  end

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "must be after start_time") if end_time <= start_time
  end

  def queue_duration_change
    return unless will_save_change_to_session_duration_minutes?

    new_value = session_duration_minutes
    old_value = session_duration_minutes_was
    return if new_value == old_value

    self.session_duration_minutes = old_value
    self.session_duration_minutes_next = new_value
    self.session_duration_effective_at = Time.current + 1.day
  end
end
