# frozen_string_literal: true

module Ver1
  class ApiApplicationController < ::ApplicationController
    respond_to :json

    after_action :verify_authorized

    rescue_from Pundit::NotAuthorizedError, with: :forbidden_request

    def forbidden_request
      render(
        json:      {
          success: false,
          message: I18n.t('controllers.errors.forbidden_request')
        }, status: :forbidden
      )
    end

    def require_login
      return if current_user

      render json:   {
        success: false,
        message: I18n.t('controllers.errors.login_required')
      }, status: :unauthorized
    end
  end
end
