
# Programming_Languages_Project_4
The purpose of this project is to design and implement a comprehensive invoicing system that allows a company to manage inventory, issue invoices with automatic tax calculations, and access sales/stock reports using a web application developed with Ruby on Rails.

## 1. Inventory Management
- Create and edit products with prices and unique SKUs
- Track incoming and outgoing stock with detailed history
- Visual low-stock alerts on dashboard and product listings
- Automatic stock updates when invoices are sent

### 2. Invoicing
- Automatic sequential invoice numbering
- Multi-client support with complete client management
- Multiple configurable tax rates (VAT, Sales Tax, Exempt, etc.)
- Automatic calculation of amounts before and after taxes
- PDF generation and download
- Invoice status tracking (Draft, Sent, Paid, Cancelled)

### 3. Tax Calculation
- Configurable tax rates with descriptions
- Line-by-line tax calculations
- Separate tax configuration to avoid billing errors
- Support for multiple tax types

### 4. Client Management
- Complete client information management
- Client history and invoice tracking
- Address and tax ID management

## Technical Architecture

The application follows Rails conventions and SOLID principles:

- **Single Responsibility**: Each model handles specific business logic
- **Open/Closed**: Services can be extended without modification
- **Liskov Substitution**: Polymorphic relationships where appropriate
- **Interface Segregation**: Focused interfaces for specific needs
- **Dependency Inversion**: Models depend on abstractions

### Key Components

- **Models**: Product, Client, Invoice, InvoiceItem, TaxRate, StockMovement
- **Services**: InvoicePdfService for PDF generation
- **Controllers**: RESTful controllers following Rails conventions
- **Views**: Bootstrap-styled responsive interface

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```

3. Setup the database:
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. Start the server:
   ```bash
   rails server
   ```

5. Visit `http://localhost:3000`


## Dependencies

- Ruby 3.1+
- Rails 8.0+
- SQLite3 (development/test)
- Bootstrap 5.2
- Prawn (PDF generation)
- Additional gems as specified in Gemfile

## File Structure

```
app/
├── controllers/    # RESTful controllers
├── models/         # Business logic and validations
├── views/          # ERB templates with Bootstrap styling
├── services/       # Business services (PDF generation)
config/
├── routes.rb       # Application routes
db/
├── migrate/        # Database migrations
├── seeds.rb        # Sample data
```
