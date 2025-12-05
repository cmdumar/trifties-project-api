module Api
  module V1
    class ReservationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_reservation, only: [:show, :update, :destroy]

      def index
        @reservations = current_user.reservations.includes(:book)
        render json: @reservations.map { |r| reservation_json(r) }
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
        {
          id: r.id,
          book: { id: r.book.id, title: r.book.title, author: r.book.author },
          status: r.status,
          reserved_at: r.reserved_at,
          expires_at: r.expires_at,
          note: r.note,
          created_at: r.created_at
        }
      end

      def authorize_owner!
        head :forbidden unless @reservation.user_id == current_user.id
      end
    end
  end
end
