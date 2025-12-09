# Stock Management Feature Implementation

## Overview
This document outlines the implementation of stock management for books, including automatic stock updates when reservations are created or cancelled.

## Changes Made

### Backend Changes

#### 1. Database Migration
- **File**: `db/migrate/20251207172734_add_stock_to_books.rb`
- Added `stock` column to `books` table
- Default value: 0, not null

#### 2. Book Model (`app/models/book.rb`)
- Added `stock` validation (must be >= 0)
- Added `available?` method: checks if book has stock > 0 and is not sold
- Added `decrease_stock!` method: decreases stock by 1 (minimum 0)
- Added `increase_stock!` method: increases stock by 1
- Added `update_status_based_on_stock!` method: automatically updates book status based on stock:
  - If stock > 0 and status is 'reserved', changes to 'available'
  - If stock == 0 and status is 'available', changes to 'reserved'

#### 3. Reservation Model (`app/models/reservation.rb`)
- Added `after_create` callback: `decrease_book_stock` - decreases stock when reservation is created
- Added `after_update` callback: `handle_status_change` - increases stock when reservation is cancelled or completed
- The callbacks automatically update book status based on stock

#### 4. Books Controller (`app/controllers/api/v1/books_controller.rb`)
- Added `stock` to `book_params` (allowed parameters)
- Added `stock` to `book_json` response

#### 5. Reservations Controller (`app/controllers/api/v1/reservations_controller.rb`)
- Updated `destroy` action to use transaction for cancellation
- Added `stock` to reservation JSON response

#### 6. Seeds File (`db/seeds.rb`)
- Updated sample books to include stock values (5 and 3 respectively)

### Frontend Changes

#### 1. Admin Page (`src/components/AdminPage.jsx`)
- Added `stock` field to form data state
- Added stock input field in the book creation/edit form (required, number type, min 0)
- Added stock column to the books table display
- Stock is included when creating/updating books

#### 2. Books List (`src/components/BooksList.jsx`)
- Added stock display: shows "X copies available" for each book
- Updated reserve button logic:
  - Shows "Reserve Book" button only when `stock > 0` and status is not 'sold'
  - Shows "Out of Stock" disabled button when `stock === 0`
- Added automatic refresh when navigating back to books page (using React Router location)
- Refreshes books list after successful reservation

## How It Works

### Creating a Reservation
1. User clicks "Reserve Book" on an available book
2. Backend validates book has stock > 0
3. Reservation is created
4. `after_create` callback decreases book stock by 1
5. Book status is updated if needed (if stock reaches 0, status changes to 'reserved')
6. Frontend refreshes to show updated stock

### Cancelling a Reservation
1. User cancels a reservation
2. Reservation status is updated to 'cancelled'
3. `after_update` callback detects status change
4. If reservation was 'active', stock is increased by 1
5. Book status is updated if needed (if stock > 0 and was 'reserved', changes to 'available')
6. When user navigates back to books page, stock is refreshed

### Book Availability Logic
- A book is available for reservation if:
  - `stock > 0`
  - `status != 'sold'`
- Book status is automatically managed:
  - When stock reaches 0: status changes to 'reserved'
  - When stock increases from 0: status changes to 'available'

## API Changes

### Books Endpoint
**Response now includes:**
```json
{
  "id": 1,
  "title": "The Hobbit",
  "stock": 5,
  ...
}
```

**Create/Update now accepts:**
```json
{
  "book": {
    "title": "The Hobbit",
    "stock": 5,
    ...
  }
}
```

### Reservations Endpoint
**Response now includes stock in book object:**
```json
{
  "id": 1,
  "book": {
    "id": 5,
    "title": "The Hobbit",
    "stock": 4,
    ...
  },
  ...
}
```

## Testing

### Test Scenarios

1. **Create Book with Stock**
   - Admin creates a book with stock = 5
   - Verify stock is displayed correctly

2. **Reserve Book**
   - User reserves a book with stock = 5
   - Verify stock decreases to 4
   - Verify book is still available if stock > 0

3. **Reserve Last Copy**
   - User reserves a book with stock = 1
   - Verify stock decreases to 0
   - Verify book status changes to 'reserved'
   - Verify "Out of Stock" button appears

4. **Cancel Reservation**
   - User cancels an active reservation
   - Verify stock increases by 1
   - Verify book status updates correctly
   - Verify book appears as available on books page

5. **Multiple Reservations**
   - Multiple users reserve the same book
   - Verify stock decreases correctly for each reservation
   - Verify stock increases correctly when reservations are cancelled

## Migration Instructions

1. Run the migration:
   ```bash
   rails db:migrate
   ```

2. Update existing books with stock (if needed):
   ```ruby
   Book.update_all(stock: 1) # Set default stock for existing books
   ```

3. Restart the Rails server

4. The frontend will automatically pick up the new stock field

## Notes

- Stock cannot go below 0 (enforced in model)
- Book status is automatically managed based on stock
- Stock updates are transactional to ensure data consistency
- Frontend automatically refreshes when navigating between pages
- Admin must set stock when creating books (required field)

