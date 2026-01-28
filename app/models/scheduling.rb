class Scheduling < ApplicationRecord
  belongs_to :diary, inverse_of: :schedulings
  belongs_to :scheduling_rule, inverse_of: :schedulings
  belongs_to :user, inverse_of: :schedulings

  validates :diary_id, presence: true
  validates :scheduling_rule_id, presence: true
  validates :user_id, presence: true
  validates :date, presence: true
  validates :time, presence: true
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :status, presence: true, inclusion: { in: %w[pending completed cancelled] }
  validates :created_at, presence: true
  validates :updated_at, presence: true

  validate :time_at_least_next_hour
  validate :matches_scheduling_rule

  private
    def scheduled_at
      return if date.blank? || time.blank?

      Time.zone.local(date.year, date.month, date.day, time.hour, time.min, time.sec)
    end

    def time_at_least_next_hour
      return if date.blank? || time.blank?

      min_time = (Time.current + 1.hour).beginning_of_hour
      return if scheduled_at && scheduled_at >= min_time

      errors.add(:time, "must be at least next hour")
    end

    def matches_scheduling_rule
      return if scheduling_rule.blank? || date.blank? || time.blank?

      if scheduling_rule.start_date && date < scheduling_rule.start_date
        errors.add(:date, "is before scheduling rule start_date")
      end

      if scheduling_rule.end_date && date > scheduling_rule.end_date
        errors.add(:date, "is after scheduling rule end_date")
      end

      if scheduling_rule.week_days.present? && !scheduling_rule.week_days.include?(date.wday)
        errors.add(:date, "is not allowed by scheduling rule")
      end

      return unless scheduling_rule.start_time && scheduling_rule.end_time

      start_seconds = scheduling_rule.start_time.seconds_since_midnight
      end_seconds = scheduling_rule.end_time.seconds_since_midnight
      time_seconds = time.seconds_since_midnight

      if time_seconds < start_seconds || time_seconds > end_seconds
        errors.add(:time, "is outside scheduling rule range")
      end
    end
end
