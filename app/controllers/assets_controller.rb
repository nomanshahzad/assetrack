class AssetsController < ApplicationController
  before_action :set_asset, only: %i[show edit update destroy]

  def index
    @assets = Asset.order(created_at: :desc)
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        pdf = AssetPdf.new(@asset)
        send_data pdf.render,
          filename: "handover-form-#{@asset.id}.pdf",
          type: "application/pdf",
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
    if @asset.update(asset_params)
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
      asset_items_attributes: [
        :id, :item_details, :is_consumable, :is_custody,
        :quantity, :is_new, :is_used, :_destroy
      ]
    )
  end
end
