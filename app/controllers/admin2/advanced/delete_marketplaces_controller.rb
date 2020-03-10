module Admin2::Advanced
  class DeleteMarketplacesController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    def destroy
      if can_delete_marketplace? && params[:delete_confirmation] == @current_community.ident
        @current_community.update(deleted: true)

        redirect_to Maybe(delete_redirect_url(APP_CONFIG)).or_else(:community_not_found)
      else
        flash[:error] = "Could not delete marketplace."
        redirect_to delete_admin2_listing_manage_listings_path
      end
    end

    private

    def can_delete_marketplace?
      PlanService::API::Api.plans.get_current(community_id: @current_community.id).data[:features][:deletable]
    end

    def set_service
      @service = Admin::SettingsService.new(
        community: @current_community,
        params: params)
      @presenter = Admin::SettingsPresenter.new(service: @service)
    end
  end
end
