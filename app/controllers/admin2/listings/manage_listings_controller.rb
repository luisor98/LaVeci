module Admin2::Listings
  class ManageListingsController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    private

    def set_service
      @service = Admin2::ListingsService.new(
        community: @current_community,
        params: params)
      @presenter = Listing::ListPresenter.new(@current_community,
                                              @current_user, params,
                                              true)
    end
  end
end
