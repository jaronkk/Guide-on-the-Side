set :cakephp_version, '2.4.10'
set :cakephp_lib_path, proc { File.join(shared_path, 'lib') }
set :cakephp_versioned_lib_path, proc { "#{fetch(:cakephp_lib_path)}-#{fetch(:cakephp_version)}" }
set :cakephp_app_path, proc { File.join(release_path, 'app') }
set :cakephp_executable_path, proc { File.join(fetch(:cakephp_lib_path), 'Cake/Console/cake') }

namespace :cakephp do
  desc "Check to see if CakePHP needs to be installed"
  task :check do
    on roles(:app) do
      if !test("[ -d #{fetch(:cakephp_versioned_lib_path)} ]")
        invoke 'cakephp:install'
      else
        invoke 'cakephp:link'
      end
    end
  end

  desc "Downloads CakePHP to shared/lib-X.X.X"
  task :install do
    on roles(:app), in: :parallel do |host|
      within shared_path do
        # Download and extract the CakePHP lib to shared/lib-X.X.X
        execute("mkdir -p #{fetch(:cakephp_versioned_lib_path)}")
        execute("wget -qO- https://github.com/cakephp/cakephp/archive/#{fetch(:cakephp_version)}.tar.gz | tar xvz -C #{fetch(:cakephp_versioned_lib_path)} cakephp-#{fetch(:cakephp_version)}/lib --strip-components 2")
      end
    end
    invoke 'cakephp:link'
  end

  task :link do
    on roles(:app) do
      # Delete the existing shared/lib if it's not a symlink
      execute("rm -rf #{fetch(:cakephp_lib_path)}")

      # Create a symlink from shared/lib to shared/lib-X.X.X
      execute("ln -f -s #{fetch(:cakephp_versioned_lib_path)} #{fetch(:cakephp_lib_path)}")
    end
  end

  def cake_command(*args)
    execute("#{fetch(:cakephp_executable_path)}", "-app #{fetch(:cakephp_app_path)}", *args)
  end

  desc "Runs CakePHP migrations"
  task :migrate do
    on roles(:app) do
      cake_command('Migrations.migration run all')
    end
  end

  namespace :migrate do
    desc "Check the status of CakePHP migrations"
    task :status do
      on roles(:app) do
        cake_command('Migrations.migration status')
      end
    end
  end
end
