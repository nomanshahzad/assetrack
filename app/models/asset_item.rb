class AssetItem < ApplicationRecord
  CONDITIONS = %w[new used].freeze

  belongs_to :asset

  validates :condition, inclusion: { in: CONDITIONS }, allow_blank: true
end
