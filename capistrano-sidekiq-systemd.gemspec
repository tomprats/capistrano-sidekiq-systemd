lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "capistrano/sidekiq/version"

Gem::Specification.new do |gem|
  gem.name        = "capistrano-sidekiq-systemd"
  gem.version     = Capistrano::Sidekiq::VERSION
  gem.authors     = ["Tom Prats"]
  gem.email       = ["tom@tomify.me"]
  gem.homepage    = "https://github.com/tomprats/capistrano-sidekiq-systemd"
  gem.license     = "MIT"
  gem.summary     = "Provides a sidekiq service through systemd"
  gem.description = <<-EOF.gsub(/^\s+/, "")
    Capistrano tasks for setting up and running sidekiq with Capistrano.

    Handles uploading the systemd service config, as well as starting,
    stopping, and restarting it whenever necessary.
  EOF

  gem.files       = `git ls-files`.split($/)
  gem.add_dependency "capistrano", ">= 3.1"
  gem.add_dependency "sshkit", ">= 1.2.0"
end
