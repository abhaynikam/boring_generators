Sentry.init do |config|
  config.dsn = <%= @sentry_dsn_key %>
  # enable performance monitoring
  config.enable_tracing = true
  # get breadcrumbs from logs
  config.breadcrumbs_logger = <%= @breadcrumbs_logger_options %>
end