module Api
  module V1
    class CategoriesController < ApplicationController
      before_action :set_category, only: [:show, :update, :destroy]
      before_action :authenticate_user!, except: [:index, :show]

      def index
        @categories = Category.all.order(:name)
        render json: @categories.map { |c| category_json(c) }
      end

      def show
        render json: category_json(@category)
      end

      def create
        @category = Category.new(category_params)
        if @category.save
          render json: category_json(@category), status: :created
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @category.update(category_params)
          render json: category_json(@category)
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @category.destroy
        head :no_content
      end

      private

      def set_category
        @category = Category.find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name, :description)
      end

      def category_json(c)
        {
          id: c.id,
          name: c.name,
          description: c.description,
          created_at: c.created_at,
          updated_at: c.updated_at
        }
      end
    end
  end
end

