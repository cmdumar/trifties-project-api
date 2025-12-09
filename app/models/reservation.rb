class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum :status, { active: 0, cancelled: 1, completed: 2 }

  validates :reserved_at, presence: true
  validate :book_must_be_available, on: :create
  validate :user_can_only_reserve_one_copy, on: :create

  after_create :decrease_book_stock
  after_update :handle_status_change

  private

  def book_must_be_available
    unless book.available?
      errors.add(:book, "is not available for reservation")
    end
  end

  def user_can_only_reserve_one_copy
    existing_reservation = user.reservations.find_by(book: book, status: :active)
    if existing_reservation && existing_reservation.id != id
      errors.add(:base, "You already have an active reservation for this book")
    end
  end

  def decrease_book_stock
    book.decrease_stock!
    book.update_status_based_on_stock!
  end

  def handle_status_change
    # If reservation was cancelled or completed, increase stock
    if saved_change_to_status? && (status == 'cancelled' || status == 'completed')
      # status_was returns the previous value before the save
      previous_status = status_was
      if previous_status == 'active' || previous_status == 0 || previous_status == :active
        book.increase_stock!
        book.update_status_based_on_stock!
      end
    end
  end
end
