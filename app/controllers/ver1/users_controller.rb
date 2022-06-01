# frozen_string_literal: true

module Ver1
  class UsersController < ApiApplicationController
    before_action :require_login

    def index
      authorize User, :index?
      pagy, records = pagy(policy_scope(User))

      render(
        json: UsersSerializer.new(
          records,
          metadata: pagy_metadata(pagy)
        ).as_json
      )
    end
  end
end
