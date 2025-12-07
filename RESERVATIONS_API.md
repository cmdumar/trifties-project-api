# Reservations API Documentation

## Overview

The Reservations API allows authenticated users to manage their book reservations. Users can view their reserved books, create new reservations, update, and cancel existing ones.

## Authentication

All endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## Endpoints

### 1. Get User's Reservations (Enhanced)

**GET** `/api/v1/reservations`

Returns a paginated list of the current user's reservations with detailed book information.

#### Query Parameters

- `status` (optional): Filter by reservation status (`active`, `cancelled`, `completed`)
- `from_date` (optional): Filter reservations from this date (format: `YYYY-MM-DD`)
- `to_date` (optional): Filter reservations until this date (format: `YYYY-MM-DD`)
- `page` (optional): Page number (default: 1)
- `per_page` (optional): Items per page (default: 20, max: 100)

#### Example Request

```bash
GET /api/v1/reservations?status=active&page=1&per_page=10
```

#### Example Response

```json
{
  "reservations": [
    {
      "id": 1,
      "book": {
        "id": 5,
        "title": "The Great Gatsby",
        "author": "F. Scott Fitzgerald",
        "isbn": "978-0-7432-7356-5",
        "price": 12.99,
        "condition": "good",
        "status": "reserved",
        "description": "A classic American novel...",
        "category": {
          "id": 2,
          "name": "Fiction"
        },
        "cover_image_url": "http://localhost:3000/rails/active_storage/blobs/..."
      },
      "status": "active",
      "reserved_at": "2025-12-06T10:30:00Z",
      "expires_at": "2025-12-09T10:30:00Z",
      "note": "Please hold at front desk",
      "created_at": "2025-12-06T10:30:00Z",
      "updated_at": "2025-12-06T10:30:00Z",
      "days_remaining": 3
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 10,
    "total_count": 25,
    "total_pages": 3
  }
}
```

### 2. Get Single Reservation

**GET** `/api/v1/reservations/:id`

Returns details of a specific reservation.

#### Example Response

```json
{
  "id": 1,
  "book": {
    "id": 5,
    "title": "The Great Gatsby",
    "author": "F. Scott Fitzgerald",
    "isbn": "978-0-7432-7356-5",
    "price": 12.99,
    "condition": "good",
    "status": "reserved",
    "description": "A classic American novel...",
    "category": {
      "id": 2,
      "name": "Fiction"
    },
    "cover_image_url": "http://localhost:3000/rails/active_storage/blobs/..."
  },
  "status": "active",
  "reserved_at": "2025-12-06T10:30:00Z",
  "expires_at": "2025-12-09T10:30:00Z",
  "note": "Please hold at front desk",
  "created_at": "2025-12-06T10:30:00Z",
  "updated_at": "2025-12-06T10:30:00Z",
  "days_remaining": 3
}
```

### 3. Create Reservation

**POST** `/api/v1/reservations`

Creates a new reservation for a book.

#### Request Body

```json
{
  "book_id": 5,
  "note": "Optional note about the reservation"
}
```

#### Example Response

```json
{
  "id": 1,
  "book": { ... },
  "status": "active",
  "reserved_at": "2025-12-06T10:30:00Z",
  "expires_at": "2025-12-09T10:30:00Z",
  "note": "Optional note about the reservation",
  "created_at": "2025-12-06T10:30:00Z",
  "updated_at": "2025-12-06T10:30:00Z",
  "days_remaining": 3
}
```

### 4. Update Reservation

**PATCH/PUT** `/api/v1/reservations/:id`

Updates a reservation (e.g., change note or status).

#### Request Body

```json
{
  "reservation": {
    "note": "Updated note",
    "status": "active"
  }
}
```

### 5. Cancel Reservation

**DELETE** `/api/v1/reservations/:id`

Cancels a reservation (sets status to `cancelled`).

#### Example Response

```json
{
  "message": "Reservation cancelled"
}
```

## User Profile Endpoint

### Get User Profile with Reservation Summary

**GET** `/api/v1/users/profile`

Returns user information along with reservation statistics and recent reservations.

#### Example Response

```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "admin": false,
    "created_at": "2025-12-01T10:00:00Z"
  },
  "reservations_summary": {
    "total": 15,
    "active": 3,
    "cancelled": 2,
    "completed": 10
  },
  "recent_reservations": [
    {
      "id": 1,
      "book": {
        "id": 5,
        "title": "The Great Gatsby",
        "author": "F. Scott Fitzgerald",
        "price": 12.99,
        "cover_image_url": "http://localhost:3000/rails/active_storage/blobs/..."
      },
      "status": "active",
      "reserved_at": "2025-12-06T10:30:00Z",
      "expires_at": "2025-12-09T10:30:00Z"
    }
  ]
}
```

## Status Values

- `active`: Reservation is currently active
- `cancelled`: Reservation was cancelled
- `completed`: Reservation was completed

## Error Responses

### 401 Unauthorized
```json
{
  "error": "Unauthorized"
}
```

### 403 Forbidden
```json
{
  "error": "Forbidden"
}
```

### 404 Not Found
```json
{
  "error": "Not Found"
}
```

### 422 Unprocessable Entity
```json
{
  "errors": [
    "Book is not available for reservation"
  ]
}
```

## Usage Examples

### Get all active reservations
```bash
curl -X GET "http://localhost:3000/api/v1/reservations?status=active" \
  -H "Authorization: Bearer <token>"
```

### Get reservations from a date range
```bash
curl -X GET "http://localhost:3000/api/v1/reservations?from_date=2025-12-01&to_date=2025-12-31" \
  -H "Authorization: Bearer <token>"
```

### Get user profile
```bash
curl -X GET "http://localhost:3000/api/v1/users/profile" \
  -H "Authorization: Bearer <token>"
```

### Create a reservation
```bash
curl -X POST "http://localhost:3000/api/v1/reservations" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "book_id": 5,
    "note": "Please hold at front desk"
  }'
```

