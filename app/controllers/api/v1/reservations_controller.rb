module Api
  module V1
    class ReservationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_reservation, only: [:show, :update, :destroy]

      def index
        @reservations = current_user.reservations.includes(:book, :book => :category)
        
        # Filter by status if provided
        @reservations = @reservations.where(status: params[:status]) if params[:status].present?
        
        # Filter by date range if provided
        if params[:from_date].present?
          @reservations = @reservations.where('reserved_at >= ?', Date.parse(params[:from_date]))
        end
        if params[:to_date].present?
          @reservations = @reservations.where('reserved_at <= ?', Date.parse(params[:to_date]).end_of_day)
        end
        
        # Order by most recent first
        @reservations = @reservations.order(reserved_at: :desc)
        
        # Pagination
        page = params[:page]&.to_i || 1
        per_page = [params[:per_page]&.to_i || 20, 100].min # max 100 per page
        offset = (page - 1) * per_page
        
        total_count = @reservations.count
        @reservations = @reservations.limit(per_page).offset(offset)
        
        render json: {
          reservations: @reservations.map { |r| reservation_json(r) },
          pagination: {
            page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: (total_count.to_f / per_page).ceil
          }
        }
      end

      def show
        authorize_owner!
        render json: reservation_json(@reservation)
      end

      def create
        book = Book.find(params[:book_id])
        reservation = current_user.reservations.new(book: book, reserved_at: Time.current, expires_at: Time.current + 3.days, note: params[:note])
        ActiveRecord::Base.transaction do
          if reservation.save
            render json: reservation_json(reservation), status: :created
          else
            render json: { errors: reservation.errors.full_messages }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
      end

      def update
        authorize_owner!
        if @reservation.update(reservation_params)
          render json: reservation_json(@reservation)
        else
          render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize_owner!
        @reservation.update!(status: :cancelled)
        # optionally destroy record: @reservation.destroy
        render json: { message: "Reservation cancelled" }
      end

      private

      def set_reservation
        @reservation = Reservation.find(params[:id])
      end

      def reservation_params
        params.require(:reservation).permit(:status, :note)
      end

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
            isbn: book.isbn,
            price: book.price.to_f,
            condition: book.condition,
            status: book.status,
            description: book.description,
            category: book.category ? { id: book.category.id, name: book.category.name } : nil,
            cover_image_url: cover_url ? "http://localhost:3000#{cover_url}" : nil
          },
          status: r.status,
          reserved_at: r.reserved_at,
          expires_at: r.expires_at,
          note: r.note,
          created_at: r.created_at,
          updated_at: r.updated_at,
          days_remaining: r.expires_at ? [(r.expires_at.to_date - Date.today).to_i, 0].max : nil
        }
      end

      def authorize_owner!
        head :forbidden unless @reservation.user_id == current_user.id
      end
    end
  end
end
