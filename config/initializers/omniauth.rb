Rails.application.config.middleware.use OmniAuth::Builder do
  client_id = ENV['GOOGLE_CLIENT_ID']
  client_secret = ENV['GOOGLE_CLIENT_SECRET']
  redirect_uri = ENV['GOOGLE_REDIRECT_URI'] || 'http://localhost:3000/auth/google_oauth2/callback'

  provider :google_oauth2, client_id, client_secret, {
    scope: 'https://www.googleapis.com/auth/spreadsheets',
    redirect_uri: redirect_uri
  }
end
