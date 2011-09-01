# encoding: utf-8

module Formize
  # @private
  class Railtie < Rails::Railtie
    initializer 'formize.initialize' do
      ActiveSupport.on_load(:action_view) do
        include Formize::FormHelper
      end
    end
  end
end
