class Diary < ApplicationRecord
  belongs_to :user, inverse_of: :diary

  has_one :scheduling_rule, dependent: :destroy, inverse_of: :diary
  has_many :schedulings, dependent: :destroy, inverse_of: :diary

  validates :user_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
end
