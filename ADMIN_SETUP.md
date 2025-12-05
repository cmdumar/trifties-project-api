# Admin Setup Guide

## Making a User an Admin

### Using Rake Tasks

**Note:** In zsh shell, you need to quote the task name with brackets:

```bash
# Correct way (with quotes)
rails 'admin:promote[user@example.com]'

# Or escape the brackets
rails admin:promote\[user@example.com\]
```

1. **Promote a user to admin:**
   ```bash
   rails 'admin:promote[user@example.com]'
   ```

2. **Remove admin status:**
   ```bash
   rails 'admin:demote[user@example.com]'
   ```

3. **List all admins:**
   ```bash
   rails admin:list
   ```

### Using Rails Console

```ruby
# Open Rails console
rails console

# Find user and make admin
user = User.find_by(email: 'user@example.com')
user.update(admin: true)

# Or in one line
User.find_by(email: 'user@example.com').update(admin: true)

# Check if user is admin
user.admin?  # => true

# List all admins
User.where(admin: true)
```

## Admin Features

- Only admins can access `/admin` page
- Only admins can create, update, or delete books
- Admin status is checked on the backend for all write operations
- Frontend automatically hides admin links for non-admin users

## Security

- Admin status is stored in the database (`users.admin` boolean field)
- Backend validates admin status before allowing write operations
- Frontend checks are for UX only - backend is the source of truth

## Troubleshooting

If admin status is not recognized:
1. Make sure the user object includes `admin: true` in the response
2. Check browser console for user object and admin status
3. Try logging out and logging back in to refresh the user data
4. Verify in Rails console: `User.find_by(email: '...').admin?`
