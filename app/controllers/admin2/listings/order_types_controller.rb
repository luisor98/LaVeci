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
      @locals = common_locals(form: @template,
                              count: 0,
                              process_summary: process_summary,
                              available_locs: available_locales)
      render layout: false
    end

    def edit
      url_name = ListingShape.find(params[:id]).name
      form = ShapeService.new(processes).get(
        community: @current_community,
        name: url_name,
        locales: available_locales.map { |_, locale| locale }
      ).data
      can_delete_res = can_delete_shape?(url_name, @current_community.shapes)
      cant_delete = !can_delete_res.success
      cant_delete_reason = cant_delete ? can_delete_res.error_msg : nil
      count = @current_community.listings.currently_open.where(listing_shape_id: form[:id]).count
      @locals = common_locals(form: form, count: count,
                              process_summary: process_summary,
                              available_locs: available_locales).merge(
        id: params[:id],
        name: pick_translation(form[:name]),
        cant_delete: cant_delete,
        cant_delete_reason: cant_delete_reason)
      render layout: false
    end

    def update
      shape = filter_uneditable_fields(FormViewLayer.params_to_shape(params), process_summary)

      url_name = ListingShape.find(params[:id]).name
      update_result = validate_shape(shape).and_then { |s|
        ShapeService.new(processes).update(
          community: @current_community,
          name: url_name,
          opts: s
        )
      }
      if update_result.success
        flash[:notice] = t("admin.listing_shapes.edit.update_success", shape: pick_translation(shape[:name]))
      else
        flash[:error] = t("admin.listing_shapes.edit.update_failure", error_msg: update_result.error_msg)
      end
      redirect_to admin2_listings_order_types
    end

    def create
      shape = filter_uneditable_fields(FormViewLayer.params_to_shape(params), process_summary)

      create_result = validate_shape(shape).and_then { |s|
        ShapeService.new(processes).create(
          community: @current_community,
          default_locale: @current_community.default_locale,
          opts: s) }
      if create_result.success
        flash[:notice] = t("admin.listing_shapes.new.create_success", shape: pick_translation(shape[:name]))
      else
        flash[:error] = t("admin.listing_shapes.new.create_failure", error_msg: create_result.error_msg)
      end
      redirect_to admin2_listings_order_types
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

    def can_delete_shape?(current_shape_name, shapes)
      listing_shapes_categories_map = shapes.map { |shape|
        [shape.name, shape.category_ids]
      }

      categories_listing_shapes_map = HashUtils.transpose(listing_shapes_categories_map)

      last_in_category_ids = categories_listing_shapes_map.select { |category_id, shape_names|
        shape_names.size == 1 && shape_names.include?(current_shape_name)
      }.keys

      shape = shapes.find { |s| s.name == current_shape_name }

      if !shape
        Result::Error.new(t("admin.listing_shapes.can_not_find_name", name: current_shape_name))
      elsif shapes.length == 1
        Result::Error.new(t("admin.listing_shapes.edit.can_not_delete_last"))
      elsif !last_in_category_ids.empty?
        categories = @current_community.categories
        category_names = pick_category_names(categories, last_in_category_ids, I18n.locale)

        Result::Error.new(t("admin.listing_shapes.edit.can_not_delete_only_one_in_categories", categories: category_names.join(", ")))
      else
        Result::Success.new(shape)
      end
    end

    def pick_translation(translations)
      translations.find { |(locale, translation)|
        locale.to_s == I18n.locale.to_s
      }.second
    end

    def validate_shape(form)
      form = Shape.call(form)

      errors = []

      if form[:shipping_enabled] && !form[:online_payments]
        errors << "Shipping cannot be enabled without online payments"
      end

      if form[:online_payments] && !form[:price_enabled]
        errors << "Online payments cannot be enabled without price"
      end

      if (form[:units].present? || form[:custom_units].present?) && !form[:price_enabled]
        errors << "Price units cannot be used without price field"
      end

      if errors.empty?
        Result::Success.new(form)
      else
        Result::Error.new(errors.join(", "))
      end
    end

    def filter_uneditable_fields(shape, process_summary)
      uneditable_keys = uneditable_fields(process_summary, shape[:author_is_seller]).select { |_, uneditable| uneditable }.keys
      shape.except(*uneditable_keys)
    end

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
