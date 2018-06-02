# Basic procfile for dev work.
# Runs all processes. Development is faster if you pick one of the other Procfiles if you don't need
# some of the processes: Procfile.rails or Procfile.express

# Development rails requires both rails and rails-assets
# (and rails-server-assets if server rendering)
rails: rails s -b '0.0.0.0' -p 3000

# Sidekiq worker
sidekiq: bundle exec sidekiq

# Render static client assets
client: sh -c 'yarn run build:dev:client'

# Render static client assets. Remove if not server rendering
server: sh -c 'yarn run build:dev:server'
