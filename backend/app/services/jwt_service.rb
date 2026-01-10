class JwtService
  include Service

  ALGORITHM = 'HS256'
  EXPIRATION_TIME = 7.days

  def call(user: nil, token: nil)
    if user
      encode(user: user)
    elsif token
      decode(token: token)
    else
      raise ArgumentError, 'Either user or token must be provided'
    end
  end

  def encode(user:)
    payload = {
      user_id: user.id,
      email: user.email,
      exp: EXPIRATION_TIME.from_now.to_i
    }

    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def decode(token:)
    decoded = JWT.decode(token, secret_key, true, { algorithm: ALGORITHM })
    decoded[0]
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    logger.error "JWT decode error: #{e.message}"
    nil
  end

  private

  def secret_key
    ENV.fetch('JWT_SECRET') do
      raise 'JWT_SECRET environment variable is not set'
    end
  end
end
