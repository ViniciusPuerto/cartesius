# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("RSpec is not running in the test environment!") unless Rails.env.test?
puts "✓ Booted in #{Rails.env} environment"

abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

# Add additional requires below this line. Rails is not loaded until this point!
require "shoulda/matchers"

# Configure FactoryBot shortcuts if using factories in the future.
RSpec.configure do |config|
  # Ensure test database is created & up-to-date before the suite runs
  config.before(:suite) do
    begin
      ActiveRecord::Migration.maintain_test_schema!
    rescue ActiveRecord::PendingMigrationError
      require "rake"
      Rails.application.load_tasks unless Rake::Task.task_defined?("db:test:prepare")
      Rake::Task["db:test:prepare"].invoke
    end
  end
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # FactoryBot
  config.include FactoryBot::Syntax::Methods if defined?(FactoryBot)

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

# Shoulda-Matchers configuration
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
