module Refinery
  module WordPress
    class Railtie < Rails::Railtie
      rake_tasks do
        load "tasks/wordpress.rake"
      end
    end
  end
end

