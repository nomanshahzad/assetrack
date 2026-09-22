class Asset < ApplicationRecord
  has_many_attached :photos

  has_many :asset_items, dependent: :destroy
  accepts_nested_attributes_for :asset_items, allow_destroy: true, reject_if: :all_blank

  validates :handover_date, presence: true
  validates :receiver_name, presence: true
  validates :receiver_employee_number, presence: true
  validates :receiver_branch_department, presence: true
  validate :acceptable_photos

  private

  def acceptable_photos
    photos.each do |photo|
      unless photo.content_type.in?(%w[image/jpeg image/png])
        errors.add(:photos, I18n.t("assets.photos.invalid_type"))
      end
      if photo.byte_size > 15.megabytes
        errors.add(:photos, I18n.t("assets.photos.too_large"))
      end
    end
  end
end
