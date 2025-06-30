
# Clear existing data
puts "Clearing existing data..."
InvoiceItem.destroy_all
Invoice.destroy_all
StockMovement.destroy_all
Product.destroy_all
Client.destroy_all
TaxRate.destroy_all

# Create Tax Rates
puts "Creating tax rates..."
vat = TaxRate.create!(
  name: "VAT",
  rate: 21.0,
  description: "Value Added Tax - Standard rate"
)

reduced_vat = TaxRate.create!(
  name: "Reduced VAT",
  rate: 10.0,
  description: "Reduced VAT rate for essential goods"
)

exempt = TaxRate.create!(
  name: "Tax Exempt",
  rate: 0.0,
  description: "Tax exempt products"
)

sales_tax = TaxRate.create!(
  name: "Sales Tax",
  rate: 8.5,
  description: "Local sales tax"
)

# Create Clients
puts "Creating clients..."
clients = [
  {
    name: "ABC Corporation",
    email: "accounting@abccorp.com",
    phone: "+1-555-0101",
    address: "123 Business Ave\nSuite 400\nNew York, NY 10001",
    tax_id: "TAX123456789"
  },
  {
    name: "XYZ Ltd",
    email: "billing@xyzltd.com",
    phone: "+1-555-0202",
    address: "456 Commerce St\nLos Angeles, CA 90210",
    tax_id: "TAX987654321"
  },
  {
    name: "Tech Solutions Inc",
    email: "finance@techsolutions.com",
    phone: "+1-555-0303",
    address: "789 Innovation Blvd\nSan Francisco, CA 94105",
    tax_id: "TAX456789123"
  },
  {
    name: "Global Enterprises",
    email: "ap@globalent.com",
    phone: "+1-555-0404",
    address: "321 International Way\nChicago, IL 60601",
    tax_id: "TAX789123456"
  },
  {
    name: "Small Business Co",
    email: "owner@smallbiz.com",
    phone: "+1-555-0505",
    address: "654 Main Street\nAnytown, TX 75001"
  }
]

created_clients = clients.map { |client_data| Client.create!(client_data) }

# Create Products
puts "Creating products..."
products = [
  {
    name: "Laptop Computer",
    sku: "TECH-001",
    description: "High-performance business laptop with 16GB RAM and 512GB SSD",
    price: 1299.99,
    stock_quantity: 25,
    minimum_stock: 5,
    tax_rate: vat
  },
  {
    name: "Wireless Mouse",
    sku: "TECH-002",
    description: "Ergonomic wireless mouse with USB receiver",
    price: 29.99,
    stock_quantity: 150,
    minimum_stock: 20,
    tax_rate: vat
  },
  {
    name: "Office Chair",
    sku: "FURN-001",
    description: "Ergonomic office chair with lumbar support",
    price: 249.99,
    stock_quantity: 8,
    minimum_stock: 10,
    tax_rate: reduced_vat
  },
  {
    name: "Desk Lamp",
    sku: "FURN-002",
    description: "LED desk lamp with adjustable brightness",
    price: 79.99,
    stock_quantity: 45,
    minimum_stock: 15,
    tax_rate: reduced_vat
  },
  {
    name: "Software License",
    sku: "SOFT-001",
    description: "Annual software license for productivity suite",
    price: 199.99,
    stock_quantity: 100,
    minimum_stock: 10,
    tax_rate: exempt
  },
  {
    name: "External Hard Drive",
    sku: "TECH-003",
    description: "1TB external USB 3.0 hard drive",
    price: 89.99,
    stock_quantity: 3,
    minimum_stock: 5,
    tax_rate: sales_tax
  },
  {
    name: "Monitor Stand",
    sku: "FURN-003",
    description: "Adjustable monitor stand with storage",
    price: 39.99,
    stock_quantity: 30,
    minimum_stock: 12,
    tax_rate: vat
  },
  {
    name: "Wireless Keyboard",
    sku: "TECH-004",
    description: "Compact wireless keyboard with number pad",
    price: 69.99,
    stock_quantity: 75,
    minimum_stock: 25,
    tax_rate: vat
  }
]

created_products = products.map { |product_data| Product.create!(product_data) }

# Create some stock movements
puts "Creating stock movements..."
created_products.each do |product|
  # Initial stock in
  product.stock_movements.create!(
    movement_type: 'in',
    quantity: product.stock_quantity,
    notes: 'Initial inventory',
    movement_date: 30.days.ago
  )

  # Some random stock movements
  if rand(2) == 0
    product.update_stock!(
      rand(5..15),
      'out',
      'Sample sale'
    )
  end

  if rand(3) == 0
    product.update_stock!(
      rand(10..30),
      'in',
      'Restocking'
    )
  end
end

# Create sample invoices
puts "Creating sample invoices..."

# Draft invoice
draft_invoice = Invoice.create!(
  client: created_clients[0],
  invoice_date: Date.current,
  due_date: 30.days.from_now.to_date,
  status: 'draft',
  notes: 'Please pay within 30 days'
)

draft_invoice.invoice_items.create!([
  {
    product: created_products[0],
    quantity: 2,
    unit_price: created_products[0].price,
    tax_rate: created_products[0].tax_rate.rate
  },
  {
    product: created_products[1],
    quantity: 4,
    unit_price: created_products[1].price,
    tax_rate: created_products[1].tax_rate.rate
  }
])

draft_invoice.calculate_totals!

# Sent invoice
sent_invoice = Invoice.create!(
  client: created_clients[1],
  invoice_date: 5.days.ago.to_date,
  due_date: 25.days.from_now.to_date,
  status: 'sent',
  notes: 'Thank you for your business'
)

sent_invoice.invoice_items.create!([
  {
    product: created_products[2],
    quantity: 3,
    unit_price: created_products[2].price,
    tax_rate: created_products[2].tax_rate.rate
  },
  {
    product: created_products[3],
    quantity: 3,
    unit_price: created_products[3].price,
    tax_rate: created_products[3].tax_rate.rate
  }
])

sent_invoice.calculate_totals!

# Paid invoice
paid_invoice = Invoice.create!(
  client: created_clients[2],
  invoice_date: 15.days.ago.to_date,
  due_date: 15.days.from_now.to_date,
  status: 'paid',
  notes: 'Payment received - thank you!'
)

paid_invoice.invoice_items.create!([
  {
    product: created_products[4],
    quantity: 5,
    unit_price: created_products[4].price,
    tax_rate: created_products[4].tax_rate.rate
  },
  {
    product: created_products[5],
    quantity: 2,
    unit_price: created_products[5].price,
    tax_rate: created_products[5].tax_rate.rate
  },
  {
    product: created_products[6],
    quantity: 1,
    unit_price: created_products[6].price,
    tax_rate: created_products[6].tax_rate.rate
  }
])

paid_invoice.calculate_totals!

puts "Seed data created successfully!"
puts "Summary:"
puts "- Tax Rates: #{TaxRate.count}"
puts "- Clients: #{Client.count}"
puts "- Products: #{Product.count}"
puts "- Stock Movements: #{StockMovement.count}"
puts "- Invoices: #{Invoice.count}"
puts "- Invoice Items: #{InvoiceItem.count}"
puts "- Low Stock Products: #{Product.low_stock.count}"
