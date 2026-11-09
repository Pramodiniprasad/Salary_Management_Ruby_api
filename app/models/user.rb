class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  enum :role, { super_admin: 0, organization_admin: 1, hr: 2, employee: 3 }
  enum :status, { active: 0, inactive: 1 }

  belongs_to :organization, optional: true
  has_one :employee, dependent: :restrict_with_error

  validates :name, presence: true
  validates :organization, presence: true, unless: :super_admin?

  def active_for_authentication?
    super && active? && (super_admin? || organization&.active?)
  end

  def inactive_message
    :inactive
  end
end
