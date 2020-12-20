Devise.setup do |config|
  config.omniauth :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end
