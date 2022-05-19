module EffectiveBootstrap
  module SaveTabs
    extend ActiveSupport::Concern

    included do

      # If there is a params[:_tabs], save it to the session
      before_action(if: -> { params[:_tabs] }) do
        session[:_tabs] = params[:_tabs]
      end

      # After we're done, delete it from session
      after_action(if: -> { session[:_tabs] }) do
        session.delete(:_tabs) unless response.redirect?
      end

    end

  end
end
