class User < ApplicationRecord
  before_validation { self.cpf = CPF.new(cpf).stripped if cpf.present? }
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, uniqueness: true, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, :address, :city, :state, :neighborhood, :birth_date, presence: true
  validates :cpf, cpf: { message: "CPF inválido" }, uniqueness: true, presence: true
  enum :status, { owner: 0, user: 1, public: 2 }, default: :public

  def full_name
    "#{first_name} #{last_name}"
  end
end
