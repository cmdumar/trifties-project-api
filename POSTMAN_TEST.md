# Postman Testing Guide

## Base URL
```
http://localhost:3000/api/v1
```

## Sign Up (Register)

**Endpoint:** `POST /users/sign_up`

**Headers:**
```
Content-Type: application/json
Accept: application/json
```

**Body (raw JSON):**
```json
{
  "user": {
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```

**Expected Response (201 Created):**
```json
{
  "message": "Signed up successfully.",
  "user": {
    "id": 1,
    "email": "test@example.com",
    "created_at": "2025-12-04T...",
    "updated_at": "2025-12-04T..."
  }
}
```

**Note:** The JWT token will be in the `Authorization` header of the response.

---

## Sign In (Login)

**Endpoint:** `POST /users/sign_in`

**Headers:**
```
Content-Type: application/json
Accept: application/json
```

**Body (raw JSON):**
```json
{
  "user": {
    "email": "test@example.com",
    "password": "password123"
  }
}
```

**Expected Response (200 OK):**
```json
{
  "message": "You are logged in.",
  "user": {
    "id": 1,
    "email": "test@example.com",
    "created_at": "2025-12-04T...",
    "updated_at": "2025-12-04T..."
  }
}
```

**Note:** The JWT token will be in the `Authorization` header of the response.

---

## Sign Out

**Endpoint:** `DELETE /users/sign_out`

**Headers:**
```
Authorization: Bearer <your_jwt_token>
Accept: application/json
```

**Expected Response (200 OK):**
```json
{
  "message": "You are logged out."
}
```

---

## Auto-Save Token in Postman

To automatically save the JWT token from responses:

1. Go to the **Tests** tab in your Postman request
2. Add this script for Sign In/Sign Up requests:

```javascript
if (pm.response.code === 200 || pm.response.code === 201) {
    const authHeader = pm.response.headers.get("Authorization");
    if (authHeader) {
        // Save just the token part (remove "Bearer " prefix)
        const token = authHeader.replace("Bearer ", "");
        pm.environment.set("token", token);
        console.log("Token saved:", token);
    }
}
```

3. Then use `{{token}}` in your Authorization header for subsequent requests:
   ```
   Bearer {{token}}
   ```

---

## Common Issues

### 406 Not Acceptable
- Make sure you include `Accept: application/json` in headers
- Check that `Content-Type: application/json` is set

### 422 Unprocessable Entity
- Check that the request body matches the expected format
- Verify password confirmation matches password
- Ensure email is valid format

### 401 Unauthorized
- Check that credentials are correct
- Verify token is valid and not expired
- Make sure token is included in Authorization header as `Bearer <token>`

