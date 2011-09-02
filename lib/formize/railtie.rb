# encoding: utf-8

module Formize
  # @private
  class Railtie < Rails::Railtie
    initializer 'formize.initialize' do
      ActiveSupport.on_load(:action_view) do
        include Formize::Helpers::AssetTagHelper
        include Formize::Helpers::TagHelper
        include Formize::Helpers::FormHelper
      end
      ActiveSupport.on_load(:action_controller) do
        include Formize::ActionController
      end
    end
  end
end
