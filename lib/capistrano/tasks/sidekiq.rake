require "erb"

namespace :load do
  task :defaults do
    set :sidekiq_app_env, -> { fetch(:rails_env) || fetch(:stage) }
    set :sidekiq_config, -> { shared_path.join("config/sidekiq.yml") }
    set :sidekiq_service, -> { "sidekiq_#{fetch(:application)}_#{fetch(:stage)}" }
  end
end

namespace :sidekiq do
  task :defaults do
    on roles :app do
      set :sidekiq_user, fetch(:sidekiq_user, deploy_user)
    end
  end

  desc "Setup Sidekiq"
  task :setup do
    invoke "sidekiq:setup_service"
    invoke "sidekiq:setup_config"
  end

  desc "Setup Sidekiq service"
  task :setup_service do
    on roles :app do
      sudo_upload! sidekiq_template("sidekiq.service"), "/etc/systemd/system/#{fetch(:sidekiq_service)}.service"
      sudo "systemctl", "daemon-reload"
      sudo "systemctl", "enable", fetch(:sidekiq_service)
    end
  end

  desc "Setup Sidekiq config"
  task :setup_config do
    on roles :app do
      execute :mkdir, "-pv", File.dirname(fetch(:sidekiq_config))
      sudo_upload! sidekiq_template("sidekiq.yml"), fetch(:sidekiq_config)
    end
  end

  [:start, :stop, :restart, :reload].each do |command|
    desc "#{command.capitalize} Sidekiq"
    task command do
      on roles :app do
        sudo "systemctl", command, fetch(:sidekiq_service)
      end
    end
  end

  before :setup_service, :defaults

  def deploy_user
    capture :id, "-un"
  end

  def sidekiq_template(template_name)
    file = "#{fetch(:templates_path)}/#{template_name}"

    return sidekiq_template_output(file) if File.exists?(file)
    return sidekiq_template_erb_output("#{file}.erb") if File.exists?("#{file}.erb")

    file = File.join(File.dirname(__FILE__), "../../generators/capistrano/sidekiq/templates/#{template_name}")

    return sidekiq_template_output(file) if File.exists?(file)
    return sidekiq_template_erb_output("#{file}.erb") if File.exists?("#{file}.erb")

    raise "#{template_name}(.erb) doesn't exist"
  end

  def sidekiq_template_erb_output(file)
    file_output = File.read(file)
    erb_output = ERB.new(file_output).result

    StringIO.new(erb_output)
  end

  def sidekiq_template_output(file)
    file_output = File.read(file)

    StringIO.new(file_output)
  end

  def sudo_upload!(from, to)
    filename = File.basename(to)
    to_dir = File.dirname(to)
    tmp_file = "#{fetch(:tmp_dir)}/#{filename}"
    upload! from, tmp_file
    sudo :mv, tmp_file, to_dir
  end
end

namespace :deploy do
  after :starting, "sidekiq:stop"
  after :published, "sidekiq:start"
  after :failed, "sidekiq:restart"
end

desc "Setup tasks"
task :setup do
  invoke "sidekiq:setup"
end
