class Book < ApplicationRecord
  belongs_to :category, optional: true
  has_many :reservations, dependent: :destroy
  has_one_attached :cover_image

  enum :status, { available: 0, reserved: 1, sold: 2 }

  validates :title, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :condition, presence: true
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  # Check if book is available for reservation (has stock > 0)
  def available?
    stock > 0 && status != 'sold'
  end

  # Decrease stock by 1
  def decrease_stock!
    update!(stock: [stock - 1, 0].max)
  end

  # Increase stock by 1
  def increase_stock!
    update!(stock: stock + 1)
  end

  # Update status based on stock
  def update_status_based_on_stock!
    if stock > 0 && status != 'sold'
      update!(status: :available) if status == 'reserved'
    elsif stock == 0 && status == 'available'
      update!(status: :reserved)
    end
  end
end
