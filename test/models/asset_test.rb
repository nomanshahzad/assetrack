require "test_helper"

class AssetTest < ActiveSupport::TestCase
  test "rejects oversized photos" do
    asset = assets(:one)
    blob = ActiveStorage::Blob.new(filename: "large.jpg", content_type: "image/jpeg",
      metadata: { identified: true }, byte_size: 16.megabytes, checksum: "unused", service_name: "test")
    asset.photos = [ blob ]
    assert_not asset.valid?
    assert_includes asset.errors[:photos], I18n.t("assets.photos.too_large")
  end
end
