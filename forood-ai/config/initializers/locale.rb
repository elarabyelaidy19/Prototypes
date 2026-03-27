Rails.application.configure do
  config.i18n.default_locale = :ar
  config.i18n.available_locales = [ :ar, :en ]
  config.i18n.fallbacks = true
end
