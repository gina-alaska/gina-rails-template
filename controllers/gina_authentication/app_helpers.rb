module GinaAuthentication
  module AppHelpers
    extend ActiveSupport::Concern

    included do
      helper_method :current_user, :signed_in?, :mirror_api
    end

    protected

    def current_user
      @current_user ||= GlobalID::Locator.locate session[:user_gid]
    rescue
      @current_user = nil
    end

    def signed_in?
      !!current_user
    end

    def signout!
      session[:user_gid] = nil
    end

    def current_user=(user)
      session[:user_gid] = user.to_global_id.to_s
    end

    def login_required!
      unless signed_in?
        flash[:warning] = "You must be logged in to view this page"
        redirect_to '/'
      end
    end

    def membership_required!
      unless signed_in? and current_user.member?
        flash[:warning] = "You do not have permission to view this page"
        redirect_to '/'
      end
    end

    def redirect_back_or_default(default_url)
      if session[:redirect_back_to]
        redirect_to session.delete(:redirect_back_to)
      else
        redirect_to default_url
      end
    end
  end
end
