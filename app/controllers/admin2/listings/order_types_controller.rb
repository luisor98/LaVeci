module Admin2::Listings
  class OrderTypesController < Admin2::AdminBaseController

    include FormViewLayer

    def index
      @category_count = @current_community.categories.count
      @listing_shapes = @current_community.shapes
      @templates = ListingShapeTemplates.new(process_summary).label_key_list
    end

    def new
      @template = ListingShapeTemplates.new(process_summary).find(params[:type_id], available_locales.map(&:second))
      # @available_locs = available_locales
      # @shape = FormViewLayer.shape_to_locals(@template)

      @locals = common_locals(form: @template,
                              count: 0,
                              process_summary: process_summary,
                              available_locs: available_locales)
      render layout: false
    end

    def process_summary
      @process_summary ||= processes.reduce({}) { |info, process|
        info[:preauthorize_available] = true if process.process == :preauthorize
        info[:request_available] = true if process.author_is_seller == false
        info
      }
    end

    def processes
      @processes ||= TransactionService::API::Api.processes.get(community_id: @current_community.id)[:data]
    end

    private

    def common_locals(form:, count:, process_summary:, available_locs:)
      { uneditable_fields: uneditable_fields(process_summary, form[:author_is_seller]),
        shape: FormViewLayer.shape_to_locals(form),
        count: count,
        harmony_in_use: APP_CONFIG.harmony_api_in_use.to_s == "true",
        display_knowledge_base_articles: APP_CONFIG.display_knowledge_base_articles.to_s == "true",
        locale_name_mapping: available_locs.map { |name, l| [l, name] }.to_h }
    end

    def uneditable_fields(process_summary, author_is_seller)
      { shipping_enabled: !process_summary[:preauthorize_available] || !author_is_seller,
        online_payments: !process_summary[:preauthorize_available] || !author_is_seller,
        availability: !process_summary[:preauthorize_available] || !author_is_seller }
    end

  end
end
