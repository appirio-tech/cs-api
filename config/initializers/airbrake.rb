Airbrake.configure do |config|
  config.api_key = 'da14214e8ee95a9c1e7b7d9bfe6d5516'
  config.host = 'collect.airbrake.io'
  config.logger = Logger.new("#{Rails.root}/log/airbrake.log")
end
