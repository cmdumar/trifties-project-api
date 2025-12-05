module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        respond_to :json
        skip_before_action :verify_signed_out_user, only: :destroy
        
        def create
          user = User.find_by(email: sign_in_params[:email])
          
          if user&.valid_password?(sign_in_params[:password])
            token = JsonWebToken.encode(user_id: user.id)
            
            render json: {
              message: 'You are logged in.',
              user: user_json(user),
              token: token
            }, status: :ok
          else
            render json: {
              message: 'Invalid email or password.',
              error: 'Authentication failed'
            }, status: :unauthorized
          end
        end

        def destroy
          # For custom JWT, we don't need to do anything server-side
          # The token will be invalidated on the client side by removing it from localStorage
          # If you want server-side token revocation, you'd need to implement a denylist
          render json: { message: 'Logged out successfully.' }, status: :ok
        rescue StandardError => e
          # Catch any errors from Devise JWT middleware and still return success
          # since we're using custom JWT tokens
          render json: { message: 'Logged out successfully.' }, status: :ok
        end

        private

        def sign_in_params
          params.require(:user).permit(:email, :password)
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
