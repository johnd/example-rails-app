set :application, 'example-rails-app'
set :repo_url, 'git@github.com:johnd/example-rails-app.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/home/app/example-rails-app'
# set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  desc 'Zero-downtime restart application'
  task :reload do
    on roles(:app), in: :sequence, wait: 5 do
      run "kill -HUP $(cat #{shared_path}/pids/unicorn.pid)"
    end
  end

  desc "Start the Unicorn process when it isn't already running."
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "cd #{current_path} && bundle exec unicorn -Dc #{current_path}/config/unicorn.rb -E production"
    end
  end

  desc "Stop the application by killing the Unicorn process"
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      if test("[ -f #{shared_path}/pids/unicorn.pid ]")
        run "kill $(cat #{shared_path}/pids/unicorn.pid)"
      end
    end
  end

  desc "Restart application"
  task :restart
  before :restart, :stop
  before :restart, :start

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end
