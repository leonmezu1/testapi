class ApplicationController < ActionController::API
  rescue_from UserAuthenticator::AuthenticationError, with: :authentication_error

  private

  def authentication_error
    error = {
      'status' => '401',
      'source' => { 'pointer' => '/code' },
      'title' => 'Authentication code is invalid',
      'detail' => 'You must provide a valid authentication code'
    }
    render json: { "errors": [error] }, status: 401
  end
end
