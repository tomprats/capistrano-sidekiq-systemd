# Capistrano Sidekiq Systemd

Capistrano tasks for setting up and running sidekiq with Capistrano.

Handles uploading the systemd service config, as well as starting,
stopping, and restarting it whenever necessary.

## Installation

Add gem to the development group in the Gemfile

```
group :development do
  gem "capistrano-sidekiq-systemd", github: "tomprats/capistrano-sidekiq-systemd"
end
```

Run `bundle install`

## Usage

Add `require "capistrano/sidekiq"` to Capfile

Make sure to run `cap setup` before deploying

## Commands

```
cap sidekiq:setup          # Setup Sidekiq
cap sidekiq:setup_config   # Setup Sidekiq config
cap sidekiq:setup_service  # Setup Sidekiq service

cap sidekiq:reload         # Reload Sidekiq
cap sidekiq:restart        # Restart Sidekiq
cap sidekiq:start          # Start Sidekiq
cap sidekiq:stop           # Stop Sidekiq
```
