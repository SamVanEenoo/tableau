class OauthController < ApplicationController
  skip_before_action :authenticate

  def silverfin_init
    redirect_to SilverfinApi.authorize_url(["user:email", "administration:read", "webhooks", "communication:write", "links", "financials:read", "financials:write", "user:firm", "workflows:read"])
  end

  def silverfin_create
    oauth_token = SilverfinApi.get_token(params[:code])
    email = JSON.parse(oauth_token.get('/api/v3/user/emails').response.body).first["email"]
    firm = JSON.parse(oauth_token.get('/api/v3/user/firm').response.body)

    user = User.find_or_initialize_by(email: email)
    user.firm_id = firm['id']
    user.firm_name = firm['name']
    user.oauth_access_token = oauth_token.to_hash
    user.save!

    original_url = session["original_url"]
    original_referrer = session["original_referrer"]

    reset_session
    session["original_referrer"] = original_referrer
    session[:current_user_id] = user.id

    redirect_to original_url || root_path
  end

  def logout
    reset_session
    redirect_to "https://live.getsilverfin.com"
  end
end
