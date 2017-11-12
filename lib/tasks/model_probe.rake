namespace :model_probe do
  desc <<~DESC
    Probe. Usage: `rails model:probe[User]`
  DESC
  task :probe, [:klass] => :environment do |task, args|
    puts args.klass.constantize.probe
  end

  desc <<~DESC
    Print fixture. Usage: `rails model:print_fixture[User]`
  DESC
  task :print_fixture, [:klass] => :environment do |task, args|
    puts args.klass.constantize.print_fixture
  end

  desc <<~DESC
    Print model. Usage: `rails model:print_model[User]`
  DESC
  task :print_model, [:klass] => :environment do |task, args|
    puts args.klass.constantize.print_model
  end
end
