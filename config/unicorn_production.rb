app_name = ENV['TORG_NAME'] || 'ksazd'
root = "/app/apps/#{app_name}/current"

working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.blog.sock"
worker_processes (ENV['NUMBER_OF_UNICORN_WORKERS'] || 5).to_i
timeout 900
