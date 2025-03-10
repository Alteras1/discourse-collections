# frozen_string_literal: true

module ::Collections
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace Collections
    config.autoload_paths << File.join(config.root, "lib")
    config.autoload_paths << File.join(config.root, "lib/collections/initializers")
  end
end
