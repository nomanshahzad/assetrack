require "test_helper"
require "open3"

class AssetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "creates a form with multiple photos" do
    assert_difference "Asset.count" do
      post assets_url, params: { asset: valid_attributes.merge(photos: [ photo, photo ]) }
    end
    assert_redirected_to asset_url(Asset.last)
    assert_equal 2, Asset.last.photos.count
    get asset_url(Asset.last)
    assert_response :success
    assert_select "img[src*='rails/active_storage']", count: 2
  end

  test "editing adds photos and preserves previous uploads" do
    asset = assets(:one)
    asset.photos.attach(photo)
    original_id = asset.photos.first.id
    patch asset_url(asset), params: { asset: { photos: [ photo, photo ] } }
    assert_redirected_to asset_url(asset)
    assert_equal 3, asset.reload.photos.count
    assert_includes asset.photos.ids, original_id
    patch asset_url(asset), params: { asset: { notes: "Updated" } }
    assert_equal 3, asset.reload.photos.count
  end

  test "edit offers removal and saves it together with new photos" do
    asset = assets(:one)
    2.times { asset.photos.attach(photo) }
    removed, retained = asset.photos.to_a
    removed_blob_id = removed.blob_id
    get edit_asset_url(asset)
    assert_select "button[data-action='photos#removePersisted']", count: 2
    assert_select "input[name='asset[remove_photo_ids][]']", count: 0

    patch asset_url(asset), params: { asset: { remove_photo_ids: [ removed.id ], photos: [ photo ] } }
    assert_redirected_to asset_url(asset)
    assert_equal 2, asset.reload.photos.count
    assert_includes asset.photos.ids, retained.id
    assert_not_includes asset.photos.ids, removed.id
    assert_not ActiveStorage::Blob.exists?(removed_blob_id)
  end

  test "removals survive validation errors without deleting saved photos" do
    asset = assets(:one)
    asset.photos.attach(photo)
    id = asset.photos.first.id
    patch asset_url(asset), params: { asset: { receiver_name: "", remove_photo_ids: [ id ] } }
    assert_response :unprocessable_entity
    assert_equal [ id ], asset.reload.photos.ids
    assert_select "input[type='hidden'][name='asset[remove_photo_ids][]'][value='#{id}']"
    assert_select "[data-photo-card][hidden]", count: 1

    patch asset_url(asset), params: { asset: { remove_photo_ids: [ id ] } }
    assert_redirected_to asset_url(asset)
    assert_empty asset.reload.photos
  end

  test "cannot remove a photo belonging to another form" do
    asset = assets(:one)
    other = assets(:two)
    asset.photos.attach(photo)
    other.photos.attach(photo)
    patch asset_url(asset), params: { asset: { remove_photo_ids: [ other.photos.first.id ] } }
    assert_redirected_to asset_url(asset)
    assert_equal 1, asset.reload.photos.count
    assert_equal 1, other.reload.photos.count
  end

  test "invalid uploads and invalid form edits do not persist attachments" do
    asset = assets(:one)
    asset.photos.attach(photo)
    patch asset_url(asset), params: { asset: { receiver_name: "", photos: [ photo ] } }
    assert_response :unprocessable_entity
    assert_equal 1, asset.reload.photos.count

    invalid = Rack::Test::UploadedFile.new(Rails.root.join("README.md"), "text/plain")
    patch asset_url(asset), params: { asset: { photos: [ invalid ] } }
    assert_response :unprocessable_entity
    assert_equal 1, asset.reload.photos.count
  end

  test "PDF includes photo pages only when attached for both company layouts" do
    asset = assets(:one)
    [ "1", "2" ].each do |logo|
      get asset_url(asset, format: :pdf, logo: logo)
      assert_response :success
      assert_equal "application/pdf", response.media_type
      assert_equal 1, response.body.scan(%r{/Type\s*/Page\b}).size
    end
    4.times { asset.photos.attach(photo) }
    [ 2, 3 ].each do |expected_pages|
      [ "1", "2" ].each do |logo|
        get asset_url(asset, format: :pdf, logo: logo)
        assert_response :success
        assert response.body.start_with?("%PDF")
        assert_equal expected_pages, response.body.scan(%r{/Type\s*/Page\b}).size
      end
      asset.photos.attach(photo) if expected_pages == 2
    end
  end

  test "photo page side borders continue through empty space to the footer" do
    begin
      Open3.capture3("pdftoppm", "-v")
    rescue Errno::ENOENT
      skip "Install poppler-utils to run PDF border rendering checks"
    end

    asset = assets(:one)
    5.times { asset.photos.attach(photo) }
    get asset_url(asset, format: :pdf)
    assert_response :success

    Tempfile.create([ "photo-borders", ".pdf" ]) do |file|
      file.binmode
      file.write(response.body)
      file.flush
      # Check both a full photo page and the last page containing only one photo.
      [ 2, 3 ].each do |page|
        ppm, error, status = Open3.capture3("pdftoppm", "-f", page.to_s,
          "-singlefile", "-scale-to", "600", file.path)
        assert status.success?, error
        header = ppm.b.match(/\AP6\s+(\d+)\s+(\d+)\s+255\s/)
        assert header, "Expected a rendered RGB page"
        width, height = header.captures.map(&:to_i)
        pixels = ppm.byteslice(header.end(0)..)
        [ (0...width / 20), (width * 19 / 20...width) ].each do |edge|
          (height / 20...height * 97 / 100).each do |y|
            green = edge.any? do |x|
              r, g, b = pixels.byteslice((y * width + x) * 3, 3).bytes
              g > r * 1.5 && g > b * 1.3
            end
            assert green, "Missing side border on PDF page #{page}, row #{y}"
          end
        end
      end
    end
  end

  private

  def photo
    Rack::Test::UploadedFile.new(Rails.root.join("app/assets/images/logo1.jpeg"), "image/jpeg")
  end

  def valid_attributes
    { handover_date: Date.current, receiver_name: "Receiver",
      receiver_employee_number: "123", receiver_branch_department: "IT" }
  end
end
