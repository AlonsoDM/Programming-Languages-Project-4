# app/services/invoice_pdf_service.rb
class InvoicePdfService
  def initialize(invoice)
    @invoice = invoice
  end

  def generate
    Prawn::Document.new do |pdf|
      # Header
      pdf.text "INVOICE", size: 30, style: :bold, align: :center
      pdf.move_down 20

      # Invoice details
      pdf.text "Invoice Number: #{@invoice.invoice_number}", size: 12, style: :bold
      pdf.text "Date: #{@invoice.invoice_date.strftime('%B %d, %Y')}"
      pdf.text "Due Date: #{@invoice.due_date&.strftime('%B %d, %Y') || 'N/A'}"
      pdf.move_down 20

      # Client information
      pdf.text "Bill To:", size: 14, style: :bold
      pdf.text @invoice.client.name
      pdf.text @invoice.client.email if @invoice.client.email.present?
      pdf.text @invoice.client.phone if @invoice.client.phone.present?
      if @invoice.client.address.present?
        pdf.text @invoice.client.address
      end
      pdf.move_down 20

      # Invoice items table
      items_data = [['Product', 'Quantity', 'Unit Price', 'Tax Rate', 'Subtotal', 'Tax', 'Total']]

      @invoice.invoice_items.each do |item|
        items_data << [
          item.product.name,
          item.quantity.to_s,
          "$#{sprintf('%.2f', item.unit_price)}",
          "#{item.tax_rate}%",
          "$#{sprintf('%.2f', item.line_total)}",
          "$#{sprintf('%.2f', item.tax_amount)}",
          "$#{sprintf('%.2f', item.line_total + item.tax_amount)}"
        ]
      end

      pdf.table(items_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        columns(2..6).align = :right
        self.row_colors = ["DDDDDD", "FFFFFF"]
        self.header = true
      end

      pdf.move_down 20

      # Totals
      pdf.move_cursor_to 150
      pdf.bounding_box([pdf.bounds.width - 200, pdf.cursor], width: 200) do
        pdf.text "Subtotal: $#{sprintf('%.2f', @invoice.subtotal)}", align: :right
        pdf.text "Tax: $#{sprintf('%.2f', @invoice.tax_amount)}", align: :right
        pdf.text "Total: $#{sprintf('%.2f', @invoice.total)}",
                size: 14, style: :bold, align: :right
      end

      # Notes
      if @invoice.notes.present?
        pdf.move_down 40
        pdf.text "Notes:", style: :bold
        pdf.text @invoice.notes
      end
    end.render
  end
end
