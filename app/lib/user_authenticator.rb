class UserAuthenticator
  class AuthenticationError < StandardError; end

  attr_reader :user

  def initialize(code)
    @code = code
  end

  def perform
    client = Octokit::Client.new(
      client_id: Rails.application.credentials.github[:client_id],
      client_secret: Rails.application.credentials.github[:client_secret]
    )
    token = client.exchange_code_for_token(code)
    res = client.exchange_code_for_token(@code)
    if res.try(:error).present?
      raise AuthenticationError
    else
      user_client Octokit::Client.new(
        access_token: token
      )
      user_data = user_client.user
    end
  end
end
