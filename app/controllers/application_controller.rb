class ApplicationController < ActionController::Base
  include Authentication
  stale_when_importmap_changes

  before_action :set_locale

  private

  def set_locale
    session[:locale] = params[:locale] if params[:locale].present?
    I18n.locale = session[:locale].presence || I18n.default_locale
  end
end
