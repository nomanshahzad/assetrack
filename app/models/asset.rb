class Asset < ApplicationRecord
  has_many :asset_items, dependent: :destroy
  accepts_nested_attributes_for :asset_items, allow_destroy: true, reject_if: :all_blank

  validates :handover_date, presence: true
  validates :receiver_name, presence: true
  validates :receiver_employee_number, presence: true
  validates :receiver_branch_department, presence: true
end
