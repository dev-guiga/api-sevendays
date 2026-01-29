class SchedulingRule < ApplicationRecord
  belongs_to :user, inverse_of: :scheduling_rules
  belongs_to :diary, inverse_of: :scheduling_rule
  has_many :schedulings, inverse_of: :scheduling_rule, dependent: :destroy

  validates :start_time, :end_time, :week_days, :session_duration_minutes, presence: true
  validates :session_duration_minutes, numericality: { only_integer: true, greater_than: 0 }

  validate :end_date_not_before_start_date

  validate :session_duration_multiple_of_15

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
end
