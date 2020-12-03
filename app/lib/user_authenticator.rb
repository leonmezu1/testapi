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
    res = client.exchange_code_for_token(code)
    if res.error.present?
      raise AuthenticationError
    else
      
    end
  end
end
