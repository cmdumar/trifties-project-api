module Api
  module V1
    module Users
      class ProfileController < ApplicationController
        before_action :authenticate_user!

        def show
          render json: {
            user: {
              id: current_user.id,
              email: current_user.email,
              admin: current_user.admin?,
              created_at: current_user.created_at
            },
            reservations_summary: {
              total: current_user.reservations.count,
              active: current_user.reservations.active.count,
              cancelled: current_user.reservations.cancelled.count,
              completed: current_user.reservations.completed.count
            },
            recent_reservations: current_user.reservations
              .includes(:book, :book => :category)
              .order(reserved_at: :desc)
              .limit(5)
              .map { |r| reservation_json(r) }
          }
        end

        private

        def reservation_json(r)
          book = r.book
          cover_url = nil
          if book.cover_image.attached?
            cover_url = Rails.application.routes.url_helpers.rails_blob_path(book.cover_image, only_path: true)
          end
          
          {
            id: r.id,
            book: {
              id: book.id,
              title: book.title,
              author: book.author,
              price: book.price.to_f,
              cover_image_url: cover_url ? "http://localhost:3000#{cover_url}" : nil
            },
            status: r.status,
            reserved_at: r.reserved_at,
            expires_at: r.expires_at
          }
        end
      end
    end
  end
end

