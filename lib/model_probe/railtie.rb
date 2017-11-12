if Rails.env.development?
  ActiveRecord::Base.extend ModelProbe

  module ModelProbe
    class Railtie < Rails::Railtie
      rake_tasks do
        load "tasks/model_probe.rake"
      end
    end
  end
end
