# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'guide_on_the_side'
set :repo_url, 'https://github.com/ndlib/Guide-on-the-Side.git'

# Default branch is :master
if fetch(:stage).to_s == 'production'
  ask :branch, 'hesburgh-master'
else
  ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
end

# deploy_to is set by the environment
set :deploy_to, proc { "#{fetch(:deploy_base)}/guide_on_the_side" }

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')
set :linked_files, fetch(:linked_files, []).push('config.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push('app/webroot/uploads', 'app/tmp/logs', 'app/tmp/sessions', 'lib')

set :php_bin_dir, proc { "#{fetch(:deploy_base)}/php/bin" }

# Default value for default_env is {}
set :default_env, proc { { path: "#{fetch(:php_bin_dir)}:$PATH" } }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

after 'deploy:check', 'cakephp:check'
before 'deploy:updated', 'cakephp:check'
