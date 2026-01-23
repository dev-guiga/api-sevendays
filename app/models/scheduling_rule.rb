class SchedulingRule < ApplicationRecord
  belongs_to :user
  belongs_to :diary

  validates :start_time, :end_time, :week_days, presence: true
  validate :end_date_not_before_start_date

  private

  def end_date_not_before_start_date
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be equal or after start_date") if end_date < start_date
  end
end
