# Inventory API

A Rails 8 API for managing book inventory with user authentication, reservations, and search capabilities.

## Prerequisites

- Ruby (check `.ruby-version` for the required version)
- PostgreSQL
- Bundler gem

## Setup Instructions

### 1. Install Dependencies

```bash
bundle install
```

### 2. Database Setup

Create and configure your PostgreSQL database:

```bash
# Create the database
rails db:create

# Run migrations
rails db:migrate

# Seed the database with sample data
rails db:seed
```

The seed file creates:
- 2 sample categories (Fiction, Non-Fiction)
- 2 sample books
- 1 test user (email: `buyer@example.com`, password: `password123`)

### 3. Configure JWT Secret Key

Set the JWT secret key as an environment variable:

```bash
export DEVISE_JWT_SECRET_KEY=$(rails secret)
```

Or add it to your `.env` file (if using dotenv gem) or set it in your shell profile.

### 4. Start the Server

```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Base URL
```
http://localhost:3000/api/v1
```

### Authentication Endpoints

#### Register a New User
```
POST /api/v1/users/sign_up
Content-Type: application/json

Body:
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```

**Response:**
```json
{
  "message": "Signed up successfully.",
  "user": {
    "id": 1,
    "email": "user@example.com"
  }
}
```

**Note:** The JWT token will be included in the `Authorization` header of the response.

#### Sign In
```
POST /api/v1/users/sign_in
Content-Type: application/json

Body:
{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}
```

**Response:**
```json
{
  "message": "You are logged in.",
  "user": {
    "id": 1,
    "email": "user@example.com"
  }
}
```

**Note:** The JWT token will be included in the `Authorization` header of the response.

#### Sign Out
```
DELETE /api/v1/users/sign_out
Authorization: Bearer <your_jwt_token>
```

### Books Endpoints

#### List All Books (Public)
```
GET /api/v1/books
```

#### Get a Book (Public)
```
GET /api/v1/books/:id
```

#### Search Books (Public)
```
GET /api/v1/books/search?title=Hobbit&author=Tolkien&category=Fiction&min_price=10&max_price=50&status=available
```

Query Parameters:
- `title` - Search by title (case-insensitive partial match)
- `author` - Search by author (case-insensitive partial match)
- `category` - Search by category name (case-insensitive partial match)
- `min_price` - Minimum price filter
- `max_price` - Maximum price filter
- `status` - Filter by status (`available`, `reserved`, `sold`)

#### Create a Book (Authenticated)
```
POST /api/v1/books
Authorization: Bearer <your_jwt_token>
Content-Type: application/json

Body:
{
  "book": {
    "title": "The Great Gatsby",
    "author": "F. Scott Fitzgerald",
    "isbn": "9780743273565",
    "description": "A classic American novel",
    "condition": "good",
    "price": 15.99,
    "status": "available",
    "category_id": 1,
    "published_at": "1925-04-10"
  }
}
```

#### Update a Book (Authenticated)
```
PATCH /api/v1/books/:id
Authorization: Bearer <your_jwt_token>
Content-Type: application/json

Body:
{
  "book": {
    "price": 12.99,
    "status": "reserved"
  }
}
```

#### Delete a Book (Authenticated)
```
DELETE /api/v1/books/:id
Authorization: Bearer <your_jwt_token>
```

### Categories Endpoints

#### List All Categories (Public)
```
GET /api/v1/categories
```

#### Get a Category (Public)
```
GET /api/v1/categories/:id
```

#### Create a Category (Authenticated)
```
POST /api/v1/categories
Authorization: Bearer <your_jwt_token>
Content-Type: application/json

Body:
{
  "category": {
    "name": "Science Fiction",
    "description": "Books about science fiction"
  }
}
```

#### Update a Category (Authenticated)
```
PATCH /api/v1/categories/:id
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

#### Delete a Category (Authenticated)
```
DELETE /api/v1/categories/:id
Authorization: Bearer <your_jwt_token>
```

### Reservations Endpoints

#### List User's Reservations (Authenticated)
```
GET /api/v1/reservations
Authorization: Bearer <your_jwt_token>
```

#### Get a Reservation (Authenticated)
```
GET /api/v1/reservations/:id
Authorization: Bearer <your_jwt_token>
```

#### Create a Reservation (Authenticated)
```
POST /api/v1/reservations
Authorization: Bearer <your_jwt_token>
Content-Type: application/json

Body:
{
  "book_id": 1,
  "note": "I'd like to reserve this book"
}
```

#### Update a Reservation (Authenticated - Owner Only)
```
PATCH /api/v1/reservations/:id
Authorization: Bearer <your_jwt_token>
Content-Type: application/json

Body:
{
  "reservation": {
    "status": "completed",
    "note": "Updated note"
  }
}
```

#### Cancel a Reservation (Authenticated - Owner Only)
```
DELETE /api/v1/reservations/:id
Authorization: Bearer <your_jwt_token>
```

## Testing with Postman

### Step 1: Set Up Environment Variables

1. Open Postman
2. Create a new Environment (e.g., "Inventory API")
3. Add the following variables:
   - `base_url`: `http://localhost:3000/api/v1`
   - `token`: (leave empty, will be set automatically)

### Step 2: Register or Sign In

#### Option A: Register a New User
1. Create a new POST request
2. URL: `{{base_url}}/users/sign_up`
3. Headers:
   - `Content-Type: application/json`
4. Body (raw JSON):
```json
{
  "user": {
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```
5. Send the request
6. Copy the `Authorization` header value from the response headers
7. Set it as the `token` environment variable (or use it directly in subsequent requests)

#### Option B: Sign In with Existing User
1. Create a new POST request
2. URL: `{{base_url}}/users/sign_in`
3. Headers:
   - `Content-Type: application/json`
4. Body (raw JSON):
```json
{
  "user": {
    "email": "buyer@example.com",
    "password": "password123"
  }
}
```
5. Send the request
6. Copy the `Authorization` header value from the response headers
7. Set it as the `token` environment variable

### Step 3: Create a Postman Collection

Create a collection with the following requests:

#### 1. Get All Books
- Method: `GET`
- URL: `{{base_url}}/books`
- No authentication required

#### 2. Search Books
- Method: `GET`
- URL: `{{base_url}}/books/search?title=Hobbit`
- No authentication required

#### 3. Get Single Book
- Method: `GET`
- URL: `{{base_url}}/books/1`
- No authentication required

#### 4. Create Book
- Method: `POST`
- URL: `{{base_url}}/books`
- Headers:
  - `Content-Type: application/json`
  - `Authorization: Bearer {{token}}`
- Body (raw JSON):
```json
{
  "book": {
    "title": "1984",
    "author": "George Orwell",
    "isbn": "9780451524935",
    "description": "A dystopian novel",
    "condition": "like_new",
    "price": 14.99,
    "status": "available",
    "category_id": 1
  }
}
```

#### 5. Update Book
- Method: `PATCH`
- URL: `{{base_url}}/books/1`
- Headers:
  - `Content-Type: application/json`
  - `Authorization: Bearer {{token}}`
- Body (raw JSON):
```json
{
  "book": {
    "price": 12.99
  }
}
```

#### 6. Delete Book
- Method: `DELETE`
- URL: `{{base_url}}/books/1`
- Headers:
  - `Authorization: Bearer {{token}}`

#### 7. Get All Categories
- Method: `GET`
- URL: `{{base_url}}/categories`
- No authentication required

#### 8. Create Category
- Method: `POST`
- URL: `{{base_url}}/categories`
- Headers:
  - `Content-Type: application/json`
  - `Authorization: Bearer {{token}}`
- Body (raw JSON):
```json
{
  "category": {
    "name": "Mystery",
    "description": "Mystery and thriller books"
  }
}
```

#### 9. Get User's Reservations
- Method: `GET`
- URL: `{{base_url}}/reservations`
- Headers:
  - `Authorization: Bearer {{token}}`

#### 10. Create Reservation
- Method: `POST`
- URL: `{{base_url}}/reservations`
- Headers:
  - `Content-Type: application/json`
  - `Authorization: Bearer {{token}}`
- Body (raw JSON):
```json
{
  "book_id": 1,
  "note": "I want to reserve this book"
}
```

#### 11. Cancel Reservation
- Method: `DELETE`
- URL: `{{base_url}}/reservations/1`
- Headers:
  - `Authorization: Bearer {{token}}`

### Step 4: Using Postman Tests to Auto-Save Token

You can add a test script to automatically save the JWT token:

1. For Sign In/Register requests, go to the "Tests" tab
2. Add this script:
```javascript
if (pm.response.code === 200 || pm.response.code === 201) {
    const authHeader = pm.response.headers.get("Authorization");
    if (authHeader) {
        pm.environment.set("token", authHeader.replace("Bearer ", ""));
    }
}
```

This will automatically extract and save the token from the Authorization header.

## Book Status Values

- `available` (0) - Book is available for reservation
- `reserved` (1) - Book is currently reserved
- `sold` (2) - Book has been sold

## Reservation Status Values

- `active` (0) - Reservation is active
- `cancelled` (1) - Reservation was cancelled
- `completed` (2) - Reservation was completed

## Troubleshooting

### JWT Token Issues
- Make sure `DEVISE_JWT_SECRET_KEY` is set
- Check that the token is included in the `Authorization` header as `Bearer <token>`
- Tokens expire after 1 day (configurable in `config/initializers/devise.rb`)

### Database Connection Issues
- Ensure PostgreSQL is running
- Check `config/database.yml` for correct database credentials
- Run `rails db:create` if the database doesn't exist

### CORS Issues
- The API is configured to allow requests from `http://localhost:3000` (frontend)
- Update `config/initializers/cors.rb` if you need to allow other origins

## Development

Run the test suite:
```bash
rails test
```

## License

[Your License Here]
