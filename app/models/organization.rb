class Organization < ApplicationRecord
  enum :status, { active: 0, inactive: 1 }

  has_many :users, dependent: :restrict_with_error
  has_many :employees, dependent: :restrict_with_error
  has_many :salaries, dependent: :restrict_with_error
  has_many :salary_slips, dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  def user_count
    users.count
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[address created_at email id name phone status updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
