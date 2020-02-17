module Admin2::Users
  class ManageUsersController < Admin2::AdminBaseController
    before_action :set_service

    def index

    end

    private

    def set_service
      @service = Admin::Communities::MembershipService.new(
        community: @current_community,
        params: params,
        current_user: @current_user)

      @presenter = Admin::MembershipPresenter.new(
        service: @service,
        params: params)
    end

  end
end
