class Book < ApplicationRecord
  belongs_to :category, optional: true
  has_many :reservations, dependent: :destroy
  has_one_attached :cover_image

  enum :status, { available: 0, reserved: 1, sold: 2 }

  validates :title, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :condition, presence: true
end
