module Admin2::Users
  class ManageUsersController < Admin2::AdminBaseController
    before_action :set_service
    # skip_before_action :verify_authenticity_token

    def index

    end

    def resend_confirmation
      @service.resend_confirmation
      render layout: false
    end

    def ban
      if @service.membership_current_user?
        raise t("admin.communities.manage_members.ban_me_error")
      end
      @service.ban
    rescue StandardError => e
      @error = e.message
    ensure
      render layout: false
    end

    def promote_admin
      if @service.removes_itself?
        raise "You cannot remove admin yourself."
      end
      @service.promote_admin
    rescue StandardError => e
      @error = e.message
    ensure
      render layout: false
    end

    def posting_allowed
      @service.posting_allowed
    rescue StandardError => e
      @error = e.message
    ensure
      render layout: false
    end

    def unban
      @service.unban
    rescue StandardError => e
      @error = e.message
    ensure
      render layout: false
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
