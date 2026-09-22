class AssetsController < ApplicationController
  COMPANIES = {
    "1" => {
      logo_filename: "logo1.jpeg",
      logo_height: 150,
      name_en: "AL HANOUF CONTRACTING GROUP",
      name_ar: "مجموعة الهنوف للمقاولات",
      side_graphic: true
    },
    "2" => {
      logo_filename: "logo2.jpeg",
      logo_height: 190,
      name_en: "HERASATEKOM EST. FOR SECURITY SERVICE",
      name_ar: "مؤسسة حراساتكم للحراسات الأمنية",
      side_graphic: false
    }
  }.freeze

  before_action :set_asset, only: %i[show edit update destroy]

  def index
    @assets = Asset.order(created_at: :desc)
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        company = COMPANIES.fetch(params[:logo], COMPANIES["1"])
        @logo_filename = company[:logo_filename]
        @logo_height = company[:logo_height]
        @company_name_en = company[:name_en]
        @company_name_ar = company[:name_ar]
        @show_side_graphic = company[:side_graphic]
        render pdf: "handover-form-#{@asset.id}",
               layout: "pdf",
               encoding: "UTF-8",
               page_size: "A4",
               orientation: "Portrait",
               margin: { top: 6, bottom: 12, left: 6, right: 6 },
               header: { content: render_to_string("assets/pdf_header", layout: false, formats: [ :html ]), spacing: 0 },
               footer: { content: render_to_string("assets/pdf_footer", layout: false, formats: [ :html ]), spacing: 0 },
               disposition: "attachment"
      end
    end
  end

  def new
    @asset = Asset.new
  end

  def create
    @asset = Asset.new(asset_params)
    if @asset.save
      redirect_to @asset, notice: "Asset handover form submitted successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @asset.update(attributes_with_photos)
      purge_removed_photo_blobs
      redirect_to @asset, notice: "Asset handover form updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @asset.destroy
    redirect_to assets_path, notice: "Asset handover form deleted."
  end

  private

  def set_asset
    @asset = Asset.find(params[:id])
  end

  # Assign together so invalid form edits cannot save attachments independently.
  def attributes_with_photos
    attributes = asset_params
    uploads = attributes.delete(:photos)&.reject(&:blank?) || []
    @existing_photos = @asset.photos.includes(:blob).to_a
    @photo_ids_to_remove = params.require(:asset).permit(remove_photo_ids: [])[:remove_photo_ids] || []
    if uploads.any? || @photo_ids_to_remove.any?
      retained = @existing_photos.reject { |photo| @photo_ids_to_remove.include?(photo.id.to_s) }
      @removed_photo_blobs = (@existing_photos - retained).map(&:blob)
      attributes[:photos] = retained.map(&:blob) + uploads
    end
    attributes
  end

  def purge_removed_photo_blobs
    Array(@removed_photo_blobs).each do |blob|
      blob.purge unless blob.attachments.exists?
    end
  end

  def asset_params
    params.require(:asset).permit(
      :handover_date,
      :receiver_name,
      :receiver_employee_number,
      :receiver_branch_department,
      :is_consumable,
      :is_custody,
      :notes,
      :delivered_by_name,
      :delivered_by_date,
      :signature_delivered_by,
      :received_by_name,
      :received_by_date,
      :signature_received_by,
      photos: [],
      asset_items_attributes: [
        :id, :item_details, :is_consumable, :is_custody,
        :quantity, :is_new, :is_used, :_destroy
      ]
    )
  end
end
