namespace :bionic do
  namespace :extensions do
    namespace :kids_closet do
      
      desc "Runs the migration of the Kids Closet extension"
      task :migrate => :environment do
        require 'bionic/extension_migrator'
        if ENV["VERSION"]
          KidsClosetExtension.migrator.migrate(ENV["VERSION"].to_i)
          Rake::Task['db:schema:dump'].invoke
        else
          KidsClosetExtension.migrator.migrate
          Rake::Task['db:schema:dump'].invoke
        end
      end
      
      desc "Copies public assets of the Kids Closet to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from KidsClosetExtension"
        Dir[KidsClosetExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(KidsClosetExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
        unless KidsClosetExtension.root.starts_with? RAILS_ROOT # don't need to copy vendored tasks
          puts "Copying rake tasks from KidsClosetExtension"
          local_tasks_path = File.join(RAILS_ROOT, %w(lib tasks))
          mkdir_p local_tasks_path, :verbose => false
          Dir[File.join KidsClosetExtension.root, %w(lib tasks *.rake)].each do |file|
            cp file, local_tasks_path, :verbose => false
          end
        end
      end
    end

  end
end
