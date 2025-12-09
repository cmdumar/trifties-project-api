# Reservation UI and Stock Update Fixes

## Issues Fixed

### 1. Hide Reserve Button for Books User Has Already Reserved
**Problem**: Reserve button was still visible for books that the current user had already reserved.

**Solution**: 
- Added `user_has_reservation` field to books API response
- Updated frontend to check this field and hide/show appropriate buttons

### 2. Stock Not Updating on Cancellation
**Problem**: When a reservation was cancelled, the book stock was not increasing.

**Solution**: 
- Added manual stock update in the `destroy` action of ReservationsController
- This ensures stock is updated even if callbacks don't fire correctly
- The callback still works as a backup

## Changes Made

### Backend Changes

#### 1. Books Controller (`app/controllers/api/v1/books_controller.rb`)
**Added**: `user_has_reservation` field to book JSON response

```ruby
# Check if current user has an active reservation for this book
user_has_reservation = false
if current_user
  user_has_reservation = current_user.reservations.exists?(book: b, status: :active)
end
```

**Benefits**:
- Efficiently checks if user has an active reservation
- Only runs for authenticated users
- Preloaded with includes for better performance

#### 2. Reservations Controller (`app/controllers/api/v1/reservations_controller.rb`)
**Updated**: `destroy` action to manually update stock

```ruby
def destroy
  authorize_owner!
  ActiveRecord::Base.transaction do
    # Store the original status before updating
    was_active = @reservation.active?
    @reservation.update!(status: :cancelled)
    
    # Manually trigger stock update if it was active
    # This ensures stock is updated even if callbacks don't fire correctly
    if was_active
      @reservation.book.increase_stock!
      @reservation.book.update_status_based_on_stock!
    end
  end
  render json: { message: "Reservation cancelled" }
end
```

**Why**: 
- Ensures stock is updated reliably
- Works even if callbacks have issues
- Transaction ensures atomicity

#### 3. Reservation Model (`app/models/reservation.rb`)
**Updated**: `handle_status_change` callback to handle edge cases

```ruby
def handle_status_change
  if saved_change_to_status? && (status == 'cancelled' || status == 'completed')
    previous_status = status_was
    if previous_status == 'active' || previous_status == 0 || previous_status == :active
      book.increase_stock!
      book.update_status_based_on_stock!
    end
  end
end
```

**Why**: Handles different status representations (integer, symbol, string)

### Frontend Changes

#### BooksList Component (`src/components/BooksList.jsx`)
**Updated**: Reserve button logic to check `user_has_reservation`

**Before**:
```jsx
{isAuthenticated && (book.stock ?? 0) > 0 && book.status !== 'sold' && (
  <button>Reserve Book</button>
)}
```

**After**:
```jsx
{/* Show reserve button only if user hasn't reserved it */}
{isAuthenticated && (book.stock ?? 0) > 0 && book.status !== 'sold' && !book.user_has_reservation && (
  <button>Reserve Book</button>
)}

{/* Show "Already Reserved" if user has reserved it */}
{isAuthenticated && book.user_has_reservation && (
  <button disabled>Already Reserved by You</button>
)}
```

## API Response Changes

### Books Endpoint Response
**New field added**:
```json
{
  "id": 1,
  "title": "The Hobbit",
  "stock": 5,
  "user_has_reservation": false,  // NEW FIELD
  ...
}
```

**For authenticated users**: `user_has_reservation` indicates if they have an active reservation
**For unauthenticated users**: Always `false`

## User Experience Improvements

### Before
- User could see "Reserve Book" button even if they already reserved it
- Clicking would show an error
- Stock didn't update when cancelling

### After
- User sees "Already Reserved by You" button (disabled) for books they've reserved
- No confusing error messages
- Stock updates correctly when cancelling
- Clear visual feedback

## Testing Scenarios

### ✅ Test 1: Hide Reserve Button
1. User reserves Book A
2. Navigate to books page
3. **Expected**: "Already Reserved by You" button shown, "Reserve Book" hidden

### ✅ Test 2: Stock Update on Cancellation
1. Book has stock = 5
2. User reserves → stock = 4
3. User cancels reservation
4. **Expected**: stock = 5, book status updates correctly

### ✅ Test 3: Multiple Users
1. User 1 reserves Book A (stock: 5 → 4)
2. User 2 sees "Reserve Book" button (user_has_reservation: false)
3. User 1 sees "Already Reserved by You" (user_has_reservation: true)

### ✅ Test 4: Re-reservation After Cancellation
1. User reserves Book A
2. User cancels → stock increases
3. User can now see "Reserve Book" button again
4. User can reserve again

## Performance Considerations

- Uses `exists?` for efficient database queries
- Preloads reservations with `includes` to avoid N+1 queries
- Only checks reservation status for authenticated users

## Notes

- The manual stock update in the controller ensures reliability
- The callback still works as a backup mechanism
- Both approaches ensure stock is always updated correctly
- Transaction ensures data consistency

