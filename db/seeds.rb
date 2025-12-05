# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# categories
fiction = Category.find_or_create_by!(name: 'Fiction')
nonfiction = Category.find_or_create_by!(name: 'Non-Fiction')

# sample books
Book.create!([
  { title: 'The Hobbit', author: 'J.R.R. Tolkien', isbn: '9780007118359', description: 'A fantasy novel', condition: 'like_new', price: 12.50, status: :available, category: fiction },
  { title: 'Eloquent Ruby', author: 'Russ Olsen', isbn: '9780321584106', description: 'Ruby programming book', condition: 'good', price: 20.00, status: :available, category: nonfiction }
])

# test user (update password)
User.create!(email: 'buyer@example.com', password: 'password123', password_confirmation: 'password123')
# jojo@admin.com , admin123