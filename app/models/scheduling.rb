class Scheduling < ApplicationRecord
  belongs_to :diary, inverse_of: :schedulings
  belongs_to :scheduling_rule, inverse_of: :schedulings
  belongs_to :user, inverse_of: :schedulings

  validates :diary_id, presence: true
  validates :scheduling_rule_id, presence: true
  validates :user_id, presence: true
  validates :date, presence: true
  validates :time, presence: true
  validates :session_duration_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :status, presence: true, inclusion: { in: %w[pending completed cancelled] }
  validates :created_at, presence: true
  validates :updated_at, presence: true

  before_validation :sync_duration_from_rule, on: :create

  validate :time_at_least_next_hour
  validate :matches_scheduling_rule
  validate :does_not_overlap_existing

  private
    def scheduled_at
      return if date.blank? || time.blank?

      time_on_date(time)
    end

    def scheduled_end_at
      return if scheduled_at.blank? || session_duration_minutes.blank?

      scheduled_at + duration_in_seconds
    end

    def time_at_least_next_hour
      return if date.blank? || time.blank?

      lead_minutes = minimum_lead_minutes
      min_time = (Time.current + lead_minutes.minutes).beginning_of_minute
      return if scheduled_at && scheduled_at >= min_time

      errors.add(:time, "must be at least #{lead_minutes} minutes ahead")
    end

    def minimum_lead_minutes
      duration = session_duration_minutes || scheduling_rule&.effective_duration_minutes
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

      return unless scheduling_rule.start_time && scheduling_rule.end_time && session_duration_minutes.present?

      start_seconds = scheduling_rule.start_time.seconds_since_midnight
      end_seconds = scheduling_rule.end_time.seconds_since_midnight
      time_seconds = time.seconds_since_midnight
      duration_seconds = duration_in_seconds

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
      return if session_duration_minutes.blank?

      start_at = scheduled_at
      end_at = scheduled_end_at
      return if start_at.blank? || end_at.blank?

      scope = diary.schedulings.where(date: date)
      scope = scope.where.not(id: id) if persisted?

      scope.find_each do |other|
        next if other.time.blank?
        next if other.status == "cancelled"
        next if other.session_duration_minutes.blank?

        other_start = time_on_date(other.time)
        other_end = other_start + other.session_duration_minutes.minutes

        if start_at < other_end && end_at > other_start
          errors.add(:time, "overlaps existing scheduling")
          break
        end
      end
    end

    def sync_duration_from_rule
      return if session_duration_minutes.present? || scheduling_rule.blank?

      self.session_duration_minutes = scheduling_rule.effective_duration_minutes
    end

    def time_on_date(clock_time)
      Time.zone.local(date.year, date.month, date.day, clock_time.hour, clock_time.min, clock_time.sec)
    end

    def duration_in_seconds
      session_duration_minutes.minutes
    end
end
