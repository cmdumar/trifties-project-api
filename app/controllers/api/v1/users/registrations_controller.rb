module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json
        
        def create
          user = User.new(sign_up_params)

          if user.save
            token = JsonWebToken.encode(user_id: user.id)
            
            render json: {
              message: 'Signed up successfully.',
              user: user_json(user),
              token: token
            }, status: :created
          else
            render json: {
              message: 'Sign up failed.',
              errors: user.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        private

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end

        def user_json(user)
          {
            id: user.id,
            email: user.email,
            admin: user.admin?,
            created_at: user.created_at,
            updated_at: user.updated_at
          }
        end
      end
    end
  end
end
