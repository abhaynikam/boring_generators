# frozen_string_literal: true

if Rails.env.development? && defined?(Bullet)
  Bullet.enable = true
  Bullet.bullet_logger = true
  Bullet.rails_logger = true
  Bullet.unused_eager_loading_enable = true
end
