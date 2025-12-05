module Api
  module V1
    class BooksController < ApplicationController
      before_action :set_book, only: [:show, :update, :destroy]
      before_action :authenticate_user!, except: [:index, :show, :search]
      before_action :ensure_admin!, only: [:create, :update, :destroy]

      def index
        @books = Book.includes(:category).order(created_at: :desc).limit(100)
        render json: @books.map { |b| book_json(b) }
      end

      def show
        render json: book_json(@book)
      end

      def create
        @book = Book.new(book_params)
        if @book.save
          render json: book_json(@book), status: :created
        else
          render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @book.update(book_params)
          render json: book_json(@book)
        else
          render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @book.destroy
        head :no_content
      end

      # composite search ?title=...&author=...&category=...&min_price=&max_price=&status=
      def search
        q = Book.all
        q = q.where("title ILIKE ?", "%#{params[:title]}%") if params[:title].present?
        q = q.where("author ILIKE ?", "%#{params[:author]}%") if params[:author].present?
        if params[:category].present?
          q = q.joins(:category).where("categories.name ILIKE ?", "%#{params[:category]}%")
        end
        if params[:min_price].present?
          q = q.where("price >= ?", params[:min_price].to_f)
        end
        if params[:max_price].present?
          q = q.where("price <= ?", params[:max_price].to_f)
        end
        q = q.where(status: params[:status]) if params[:status].present?

        render json: q.limit(200).map { |b| book_json(b) }
      end

      private

      def set_book
        @book = Book.find(params[:id])
      end

      def book_params
        params.require(:book).permit(:title, :author, :isbn, :description, :condition, :price, :status, :category_id, :published_at, :cover_image)
      end

      def ensure_admin!
        unless current_user&.admin?
          render json: { error: 'Admin access required' }, status: :forbidden
        end
      end

      def book_json(b)
        cover_url = nil
        if b.cover_image.attached?
          cover_url = Rails.application.routes.url_helpers.rails_blob_path(b.cover_image, only_path: true)
        end
        
        {
          id: b.id,
          title: b.title,
          author: b.author,
          isbn: b.isbn,
          description: b.description,
          condition: b.condition,
          price: b.price.to_f,
          status: b.status,
          category: (b.category && { id: b.category.id, name: b.category.name }),
          published_at: b.published_at,
          cover_image_url: cover_url ? "http://localhost:3000#{cover_url}" : nil,
          created_at: b.created_at,
          updated_at: b.updated_at
        }
      end
    end
  end
end
