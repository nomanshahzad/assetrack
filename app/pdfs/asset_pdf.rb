require "prawn"
require "prawn/table"

class AssetPdf
  FONT_NORMAL = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
  FONT_BOLD   = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

  PAGE_MARGIN  = 40
  ACCENT_COLOR = "4F46E5"  # indigo-600
  BORDER_COLOR = "E2E8F0"  # slate-200
  LABEL_COLOR  = "64748B"  # slate-500
  TEXT_COLOR   = "0F172A"  # slate-900

  def initialize(asset)
    @asset = asset
    @pdf = Prawn::Document.new(page_size: "A4", margin: PAGE_MARGIN)
    @pdf.font_families.update(
      "DejaVu" => { normal: FONT_NORMAL, bold: FONT_BOLD }
    )
    @pdf.font "DejaVu"
    @width = @pdf.bounds.width
  end

  def render
    header
    section_date
    section_receiver
    section_item_type
    section_items_table
    section_notes
    section_signatures
    page_numbers
    @pdf.render
  end

  private

  # ── Helpers ──────────────────────────────────────────────────────────────

  def label(text)
    @pdf.fill_color LABEL_COLOR
    @pdf.text text, size: 8
    @pdf.fill_color TEXT_COLOR
  end

  def value(text)
    @pdf.text text.presence || "—", size: 10, style: :bold
  end

  def section_title(text)
    @pdf.fill_color ACCENT_COLOR
    @pdf.fill_rectangle [@pdf.bounds.left, @pdf.cursor], @width, 20
    @pdf.fill_color "FFFFFF"
    @pdf.text_box text,
      at: [@pdf.bounds.left + 8, @pdf.cursor - 5],
      width: @width - 16,
      size: 9,
      style: :bold
    @pdf.fill_color TEXT_COLOR
    @pdf.move_down 26
  end

  def separator
    @pdf.move_down 6
    @pdf.stroke_color BORDER_COLOR
    @pdf.stroke_horizontal_rule
    @pdf.stroke_color "000000"
    @pdf.move_down 10
  end

  def field_pair(label1, value1, label2, value2)
    half = (@width - 20) / 2
    @pdf.bounding_box([@pdf.bounds.left, @pdf.cursor], width: half) do
      label label1
      value value1
    end
    @pdf.bounding_box([@pdf.bounds.left + half + 20, @pdf.cursor + 24], width: half) do
      label label2
      value value2
    end
    @pdf.move_down 28
  end

  def field_triple(l1, v1, l2, v2, l3, v3)
    third = (@width - 30) / 3
    [[l1, v1, 0], [l2, v2, third + 15], [l3, v3, (third + 15) * 2]].each do |l, v, offset|
      @pdf.bounding_box([@pdf.bounds.left + offset, @pdf.cursor], width: third) do
        label l
        value v
      end
    end
    @pdf.move_down 28
  end

  def render_signature(sig_data_url, box_width, box_height)
    if sig_data_url.present?
      begin
        raw = Base64.decode64(sig_data_url.sub(/\Adata:image\/[^;]+;base64,/, ""))
        @pdf.image StringIO.new(raw), width: box_width, height: box_height, position: :center
      rescue
        @pdf.move_down box_height
      end
    else
      @pdf.move_down box_height
    end
  end

  # ── Sections ─────────────────────────────────────────────────────────────

  def header
    @pdf.fill_color ACCENT_COLOR
    @pdf.text "Asset Handover Form", size: 20, style: :bold
    @pdf.fill_color LABEL_COLOR
    @pdf.text "Form ##{@asset.id}", size: 9
    @pdf.fill_color TEXT_COLOR
    @pdf.move_down 14
    @pdf.stroke_color ACCENT_COLOR
    @pdf.line_width 1.5
    @pdf.stroke_horizontal_rule
    @pdf.stroke_color "000000"
    @pdf.line_width 1
    @pdf.move_down 14
  end

  def section_date
    section_title "DATE"
    label "Handover Date"
    value @asset.handover_date&.strftime("%B %d, %Y")
    @pdf.move_down 14
  end

  def section_receiver
    section_title "RECEIVER INFORMATION"
    field_triple(
      "Name",             @asset.receiver_name,
      "Employee Number",  @asset.receiver_employee_number,
      "Branch / Department", @asset.receiver_branch_department
    )
  end

  def section_item_type
    section_title "ITEM TYPE"
    types = []
    types << "Consumable" if @asset.is_consumable?
    types << "Custody / Assigned Asset" if @asset.is_custody?
    value types.any? ? types.join("   •   ") : "—"
    @pdf.move_down 14
  end

  def section_items_table
    section_title "ITEM DETAILS TABLE"

    items = @asset.asset_items.to_a
    if items.empty?
      @pdf.fill_color LABEL_COLOR
      @pdf.text "No items added.", size: 9
      @pdf.fill_color TEXT_COLOR
      @pdf.move_down 14
      return
    end

    headers = ["No.", "Item Details", "Consumable", "Custody", "Qty", "New", "Used"]
    rows = items.each_with_index.map do |item, i|
      [
        (i + 1).to_s,
        item.item_details.presence || "—",
        item.is_consumable? ? "✓" : "—",
        item.is_custody?    ? "✓" : "—",
        item.quantity.presence&.to_s || "—",
        item.is_new?  ? "✓" : "—",
        item.is_used? ? "✓" : "—"
      ]
    end

    @pdf.table([headers] + rows,
      width: @width,
      cell_style: { size: 9, padding: [5, 6], border_color: "CBD5E1" },
      header: true
    ) do
      row(0).font_style = :bold
      row(0).background_color = "F1F5F9"
      row(0).text_color = "475569"
      columns(0).align = :center
      columns(2..6).align = :center
      columns(0).width = 28
      columns(4..6).width = 36
    end
    @pdf.move_down 14
  end

  def section_notes
    section_title "NOTES"
    if @asset.notes.present?
      @pdf.text @asset.notes, size: 10, leading: 3
    else
      @pdf.fill_color LABEL_COLOR
      @pdf.text "No notes added.", size: 9
      @pdf.fill_color TEXT_COLOR
    end
    @pdf.move_down 14
  end

  def section_signatures
    section_title "SIGNATURES"

    half = (@width - 20) / 2
    sig_box_height = 80
    top = @pdf.cursor

    # Delivered By column
    @pdf.bounding_box([@pdf.bounds.left, top], width: half) do
      label "Delivered By — Name"
      value @asset.delivered_by_name
      @pdf.move_down 6
      label "Date"
      value @asset.delivered_by_date&.strftime("%B %d, %Y")
      @pdf.move_down 10
      label "Signature"
      @pdf.move_down 4
      @pdf.stroke_color BORDER_COLOR
      @pdf.stroke_rectangle [@pdf.bounds.left, @pdf.cursor], half, sig_box_height
      @pdf.stroke_color "000000"
      render_signature(@asset.signature_delivered_by, half - 4, sig_box_height - 4)
    end

    # Received By column
    @pdf.bounding_box([@pdf.bounds.left + half + 20, top], width: half) do
      label "Received By — Name"
      value @asset.received_by_name
      @pdf.move_down 6
      label "Date"
      value @asset.received_by_date&.strftime("%B %d, %Y")
      @pdf.move_down 10
      label "Signature"
      @pdf.move_down 4
      @pdf.stroke_color BORDER_COLOR
      @pdf.stroke_rectangle [@pdf.bounds.left, @pdf.cursor], half, sig_box_height
      @pdf.stroke_color "000000"
      render_signature(@asset.signature_received_by, half - 4, sig_box_height - 4)
    end

    @pdf.move_down sig_box_height + 10
  end

  def page_numbers
    @pdf.number_pages "<page> / <total>",
      at: [@pdf.bounds.right - 60, 0],
      size: 8,
      color: LABEL_COLOR
  end
end
