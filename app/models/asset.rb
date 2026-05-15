class Asset < ApplicationRecord
  validates :handover_date, presence: true
  validates :receiver_name, presence: true
  validates :receiver_employee_number, presence: true
  validates :receiver_branch_department, presence: true
end
