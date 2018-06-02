set :user, 'deployer'

set :repo_url, 'git@github.com:LtdArink-Group/ksazd-rushydro.git'
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, -> { "/home/#{fetch(:user)}/apps/#{fetch(:application)}" }
set :unicorn, -> { "ln -nfs #{fetch(:deploy_to)}/current/config/unicorn_init.sh /etc/init.d/#{fetch(:application)}_unicorn" }
set :sidekiq, -> { "ln -nfs #{fetch(:deploy_to)}/current/config/torg_sidekiq.conf /etc/init/#{fetch(:application)}_sidekiq.conf" }
set :nginx, -> { "ln -nfs #{fetch(:deploy_to)}/current/config/#{fetch(:application)}_nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}" }

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :linked_files, %w[config/carrierwave_config.yml config/newrelic.yml config/redis.yml]
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
# set :linked_dirs, %w{bin log tmp/pids public/system public/uploads}
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        true
set :deploy_via,      :remote_cache
set :ssh_options,     forward_agent: true, user: fetch(:user), keys: %w[~/.ssh/id_rsa.pub]
set :rbenv_ruby, '2.4.4'
set :rbenv_path, "/home/#{fetch(:user)}/.rbenv"

namespace :deploy do

  # after 'deploy:publishing', 'deploy:restart'

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      sudo "service #{fetch(:application)}_unicorn restart"
      sudo "service #{fetch(:application)}_sidekiq restart"
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', :make_dirs
      invoke 'deploy'
    end
  end

  desc 'Copy API documentation to production'
  after :restart, :copy_docs do
    on roles(:app) do
      upload!(
        File.expand_path('../../doc/api', __FILE__),
        "#{deploy_to}/current/doc",
        recursive: true
      )
    end
  end

  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
      sudo fetch(:unicorn)
      sudo fetch(:sidekiq)
      sudo fetch(:nginx)
      # reboot server after this
    end
  end

  after :finishing, :compile_assets
  after :finishing, :cleanup
  after :finishing, :restart

  namespace :symlink do
    after :release, 'webpack:copy_assets'
  end
end

namespace :webpack do
  task :copy_assets do
    on roles(:web) do
      path = "#{fetch(:deploy_to)}/current/public/webpack/"
      execute "mkdir -p #{path}staging"
      execute "cp #{path}production/* #{path}staging/"
    end
  end
end
