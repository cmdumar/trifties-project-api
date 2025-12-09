# Reservation Fixes - Unique Constraint and Stock Updates

## Problem
Users were getting `PG::UniqueViolation` errors when trying to reserve a book they had previously reserved, even after cancelling. Additionally, stock wasn't properly updating when reservations were cancelled.

## Solutions Implemented

### 1. Partial Unique Index Migration
**File**: `db/migrate/20251207173919_update_reservations_unique_index_to_partial.rb`

**Change**: Modified the unique constraint to only apply to **active** reservations.

**Before**: Unique constraint on `(user_id, book_id)` prevented ANY duplicate reservation, even cancelled ones.

**After**: Partial unique index on `(user_id, book_id)` where `status = 0` (active), allowing:
- Users to have only one **active** reservation per book
- Users to create new reservations after cancelling previous ones
- Multiple cancelled/completed reservations for the same book

**SQL Generated**:
```sql
CREATE UNIQUE INDEX index_res_on_user_and_book_active 
ON reservations (user_id, book_id) 
WHERE status = 0;
```

### 2. Reservation Model Validation
**File**: `app/models/reservation.rb`

**Added**: `user_can_only_reserve_one_copy` validation that checks for existing active reservations before creating a new one.

**Benefits**:
- Provides user-friendly error messages
- Prevents unnecessary database queries
- Works in conjunction with the partial unique index

### 3. Controller Error Handling
**File**: `app/controllers/api/v1/reservations_controller.rb`

**Improvements**:
- Checks for existing active reservations before attempting to create
- Handles `ActiveRecord::RecordNotUnique` exceptions gracefully
- Returns helpful error messages with existing reservation details
- Prevents duplicate reservation attempts

### 4. Stock Update on Cancellation
**File**: `app/models/reservation.rb`

**Logic**: The `handle_status_change` callback properly handles stock updates:
- When a reservation status changes to 'cancelled' or 'completed'
- If the previous status was 'active', stock is increased
- Book status is automatically updated based on new stock level

**Flow**:
1. User cancels reservation → status changes to 'cancelled'
2. `after_update` callback triggers `handle_status_change`
3. If `status_was == 'active'`:
   - `book.increase_stock!` is called
   - `book.update_status_based_on_stock!` updates book status
4. Stock increases by 1, book becomes available if stock > 0

### 5. Frontend Improvements
**Files**: 
- `src/components/BooksList.jsx`
- `src/components/Reservations.jsx`

**Changes**:
- Better error handling for duplicate reservation attempts
- Suggests viewing reservations if user already has one
- Improved cancellation confirmation message
- Success message confirms stock update

## How It Works Now

### Creating a Reservation
1. User clicks "Reserve Book"
2. Frontend sends request to backend
3. Backend checks:
   - Does user already have an active reservation? → Return error
   - Is book available (stock > 0)? → Return error if not
4. If checks pass:
   - Create reservation
   - Decrease book stock by 1
   - Update book status if needed
5. Return success response

### Cancelling a Reservation
1. User clicks "Cancel Reservation"
2. Confirmation dialog appears
3. User confirms
4. Backend updates reservation status to 'cancelled'
5. `after_update` callback triggers:
   - Increases book stock by 1
   - Updates book status (if stock goes from 0 to >0, status becomes 'available')
6. Frontend refreshes reservations list
7. When user navigates to books page, stock is updated

### Re-reserving After Cancellation
1. User cancels a reservation
2. Reservation status becomes 'cancelled'
3. User can now create a new reservation for the same book
4. Partial unique index allows this because it only enforces uniqueness for active reservations

## Database Schema Changes

### Before
```sql
CREATE UNIQUE INDEX index_res_on_user_and_book 
ON reservations (user_id, book_id);
```

### After
```sql
CREATE UNIQUE INDEX index_res_on_user_and_book_active 
ON reservations (user_id, book_id) 
WHERE status = 0;  -- Only for active reservations
```

## Testing Scenarios

### ✅ Test 1: Single Active Reservation
- User reserves Book A
- User tries to reserve Book A again
- **Expected**: Error message "You already have an active reservation for this book"

### ✅ Test 2: Cancel and Re-reserve
- User reserves Book A
- User cancels reservation
- User reserves Book A again
- **Expected**: Success - new reservation created, stock decreases

### ✅ Test 3: Stock Update on Cancellation
- Book has stock = 5
- User reserves → stock = 4
- User cancels → stock = 5
- **Expected**: Stock increases correctly, book status updates

### ✅ Test 4: Multiple Users, Same Book
- User 1 reserves Book A (stock: 5 → 4)
- User 2 reserves Book A (stock: 4 → 3)
- **Expected**: Both can reserve, stock decreases for each

### ✅ Test 5: Last Copy Reservation
- Book has stock = 1
- User reserves → stock = 0, status = 'reserved'
- User cancels → stock = 1, status = 'available'
- **Expected**: Stock and status update correctly

## Migration Instructions

The migration has already been run. If you need to rollback:

```bash
rails db:rollback
```

To re-run:
```bash
rails db:migrate
```

## Notes

- The partial unique index is PostgreSQL-specific
- If using a different database, you may need to adjust the migration
- The validation in the model provides an additional layer of protection
- Stock updates are transactional and atomic
- Book status is automatically managed based on stock levels

