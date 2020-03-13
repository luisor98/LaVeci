module Admin2::TransactionsReviews
  class ManageReviewsController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    def show_review
      tx = @service.transaction
      @review = { reviewReadLabel: "Reviews for the transaction for '#{tx.title_listing}'",
                  customer_title: "Customer review from #{tx.customer_title}",
                  customer_status: tx.customer_status,
                  customer_text: tx.customer_text,
                  provider_title: "Provider review from #{tx.provider_title}",
                  provider_status: tx.provider_status,
                  provider_text: tx.provider_text }
      render layout: false
    end

    def edit_review
      @tx = @service.transaction
      render layout: false
    end

    def delete_review
      @tx = @service.transaction
      render layout: false
    end

    def destroy

    end

    def update_review
      @service.unskip
      @service.update_customer_rating
      @service.update_provider_rating
      redirect_to admin2_transactions_reviews_manage_reviews_path
    end

    private

    def set_service
      @service = Admin2::TestimonialsService.new(
        community: @current_community,
        params: params)
    end
  end
end
