class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate

  helper_method :current_user

  private

  def current_user
    @_current_user ||= session[:current_user_id] && User.find_by(id: session[:current_user_id])
  end

  def authenticate
    unless current_user
      session["original_url"] = request.fullpath
      session["original_referrer"] = request.referer
      redirect_to oauth_connect_with_silverfin_path
    end
  end

  def api
    SilverfinApi.new(user: current_user,
                     oauth_access_token: current_user.oauth_access_token)
  end
end
