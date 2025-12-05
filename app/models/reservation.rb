class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum :status, { active: 0, cancelled: 1, completed: 2 }

  validates :reserved_at, presence: true
  validate :book_must_be_available, on: :create

  after_create :mark_book_reserved
  after_destroy :release_book_if_needed

  private

  def book_must_be_available
    unless book.available?
      errors.add(:book, "is not available for reservation")
    end
  end

  def mark_book_reserved
    book.update!(status: :reserved)
  end

  def release_book_if_needed
    # optionally set book back to available if no other active reservations exist
    if book.reservations.active.count.zero?
      book.update!(status: :available)
    end
  end
end
