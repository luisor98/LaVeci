module Admin2::TransactionsReviews
  class ManageReviewsController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    private

    def set_service
      @service = Admin::TestimonialsService.new(
        community: @current_community,
        params: params)
    end
  end
end
