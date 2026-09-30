class Asset < ApplicationRecord
  has_many_attached :photos

  has_many :asset_items, dependent: :destroy
  accepts_nested_attributes_for :asset_items, allow_destroy: true, reject_if: :all_blank

  validates :handover_date, presence: true
  validates :receiver_name, presence: true
  validates :receiver_employee_number, presence: true
  validates :receiver_branch_department, presence: true
  validate :acceptable_photos

  scope :search, ->(query) {
    return all if query.blank?
    q = "%#{sanitize_sql_like(query.downcase)}%"
    where("LOWER(receiver_name) LIKE :q OR LOWER(receiver_employee_number) LIKE :q OR LOWER(receiver_branch_department) LIKE :q", q: q)
      .or(where(id: AssetItem.where("LOWER(item_details) LIKE ?", q).select(:asset_id)))
  }

  scope :by_date_range, ->(date_from, date_to) {
    rel = all
    rel = rel.where("handover_date >= ?", date_from) if date_from.present?
    rel = rel.where("handover_date <= ?", date_to) if date_to.present?
    rel
  }

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
