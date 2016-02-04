require "ama_layout/version"
require "rails/all"
require "foundation-rails"
require "sass-rails"
require "font-awesome-sass"
require "draper"
require "browser"
require "ama_layout/moneris"
require "ama_layout/navigation"
require "ama_layout/navigation_item"
require "ama_layout/decorators/moneris_decorator"
require "ama_layout/decorators/navigation_decorator"
require "ama_layout/decorators/navigation_item_decorator"
require "ama_layout/controllers/action_controller.rb"

module AmaLayout
  module Rails
    class Engine < ::Rails::Engine
      initializer('ama_layout') do
        I18n.load_path << File.join(self.root, 'app', 'config', 'locales', 'en.yml')
        ::ActionController::Base.send :include, AmaLayout::ActionController
      end
    end
  end
end
