class Diary < ApplicationRecord
  belongs_to :user

  has_one :scheduling_rule, dependent: :destroy
  has_many :schedulings, dependent: :destroy

  validates :user_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
end
