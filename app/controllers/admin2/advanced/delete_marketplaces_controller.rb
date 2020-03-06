module Admin2::Advanced
  class DeleteMarketplacesController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    private

    def set_service
      @service = Admin::SettingsService.new(
        community: @current_community,
        params: params)
      @presenter = Admin::SettingsPresenter.new(service: @service)
    end

  end
end
