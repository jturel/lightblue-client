require 'lightblue'
require 'rails'
module Lightblue
  class Railtie < Rails::Railtie
    railtie_name :lightblue

    rake_tasks do
      load 'tasks/lightblue.rake'
    end
  end
end
