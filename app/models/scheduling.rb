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
  validate :does_not_overlap_existing

  private
    def scheduled_at
      return if date.blank? || time.blank?

      Time.zone.local(date.year, date.month, date.day, time.hour, time.min, time.sec)
    end

    def scheduled_end_at
      return if scheduled_at.blank? || scheduling_rule&.session_duration_minutes.blank?

      scheduled_at + scheduling_rule.session_duration_minutes.minutes
    end

    def time_at_least_next_hour
      return if date.blank? || time.blank?

      lead_minutes = minimum_lead_minutes
      min_time = (Time.current + lead_minutes.minutes).beginning_of_minute
      return if scheduled_at && scheduled_at >= min_time

      errors.add(:time, "must be at least #{lead_minutes} minutes ahead")
    end

    def minimum_lead_minutes
      duration = scheduling_rule&.session_duration_minutes
      return 60 if duration.blank?

      duration.between?(15, 45) ? 30 : 60
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

      return unless scheduling_rule.start_time && scheduling_rule.end_time && scheduling_rule.session_duration_minutes.present?

      start_seconds = scheduling_rule.start_time.seconds_since_midnight
      end_seconds = scheduling_rule.end_time.seconds_since_midnight
      time_seconds = time.seconds_since_midnight
      duration_seconds = scheduling_rule.session_duration_minutes.minutes

      if time_seconds < start_seconds || time_seconds + duration_seconds > end_seconds
        errors.add(:time, "is outside scheduling rule range")
        return
      end

      offset_seconds = time_seconds - start_seconds
      if duration_seconds > 0 && (offset_seconds % duration_seconds).nonzero?
        errors.add(:time, "does not align with scheduling rule duration")
      end
    end

    def does_not_overlap_existing
      return if diary.blank? || date.blank? || time.blank?
      return if scheduling_rule.blank? || scheduling_rule.session_duration_minutes.blank?

      start_at = scheduled_at
      end_at = scheduled_end_at
      return if start_at.blank? || end_at.blank?

      scope = diary.schedulings.where(date: date)
      scope = scope.where.not(id: id) if persisted?

      scope.find_each do |other|
        next if other.time.blank?
        other_rule = other.scheduling_rule
        next if other_rule.blank? || other_rule.session_duration_minutes.blank?

        other_start = Time.zone.local(date.year, date.month, date.day, other.time.hour, other.time.min, other.time.sec)
        other_end = other_start + other_rule.session_duration_minutes.minutes

        if start_at < other_end && end_at > other_start
          errors.add(:time, "overlaps existing scheduling")
          break
        end
      end
    end
end
