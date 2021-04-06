# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Configure CORS
  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins 'https://staging-scl.herokuapp.com',
              'https://www.staging-scl.herokuapp.com',
              'localhost:3000', '127.0.0.1:3000',
              'localhost:4000', '127.0.0.1:4000',
              'https://staging-scl.netlify.app',
              'https://www.staging-scl.netlify.app'

      resource '/campaigns',
               methods: [:get],
               headers: :any,
               expose: %w[Total-Count Total-Pages Page-Items Current-Page]
      resource '*', headers: :any, methods: :any
    end
  end

  # Show full error reports.
  config.consider_all_requests_local = false

  config.action_controller.perform_caching = true

  config.cache_store = :mem_cache_store,
                       (ENV['MEMCACHIER_SERVERS'] || '').split(','),
                       { username: ENV['MEMCACHIER_USERNAME'],
                         password: ENV['MEMCACHIER_PASSWORD'],
                         failover: true,
                         socket_timeout: 1.5,
                         socket_failure_delay: 0.2,
                         down_retry_delay: 60,
                         pool_size: 5 }

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Store uploaded files on the local file system (see config/storage.yml for
  # options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
