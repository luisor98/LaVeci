module Admin2::Listings
  class ListingFieldsController < Admin2::AdminBaseController

    before_action :field_type_is_valid, only: %i[new create]

    CHECKBOX_TO_BOOLEAN = ->(v) {
      if v == false || v == true
        v
      else
        v == "1"
      end
    }

    HASH_VALUES = ->(v) {
      if v.is_a?(Array)
        v
      elsif v.is_a?(Hash)
        v.values
      elsif v == nil
        nil
      else
        raise ArgumentError.new("Illegal argument given to transformer: #{v.to_inspect}")
      end
    }

    CategoryAttributeSpec = EntityUtils.define_builder(
      [:category_id, :fixnum, :to_integer, :mandatory]
    )

    OptionAttribute = EntityUtils.define_builder(
      [:id, :mandatory],
      [:sort_priority, :fixnum, :to_integer, :mandatory],
      [:title_attributes, :hash, :to_hash, :mandatory]
    )

    CUSTOM_FIELD_SPEC = [
      [:name_attributes, :hash, :mandatory],
      [:category_attributes, collection: CategoryAttributeSpec],
      [:sort_priority, :fixnum, :optional],
      [:required, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN],
      [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
    ]

    TextFieldSpec = [
      [:search_filter, :bool, const_value: false]
    ] + CUSTOM_FIELD_SPEC

    NumericFieldSpec = [
      [:min, :mandatory],
      [:max, :mandatory],
      [:allow_decimals, :bool, :mandatory, transform_with: CHECKBOX_TO_BOOLEAN],
      [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
    ] + CUSTOM_FIELD_SPEC

    DropdownFieldSpec = [
      [:option_attributes, :mandatory, transform_with: HASH_VALUES, collection: OptionAttribute],
      [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN],
    ] + CUSTOM_FIELD_SPEC

    CheckboxFieldSpec = [
      [:option_attributes, :mandatory, transform_with: HASH_VALUES, collection: OptionAttribute],
      [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
    ] + CUSTOM_FIELD_SPEC

    DateFieldSpec = [
      [:search_filter, :bool, const_value: false]
    ] + CUSTOM_FIELD_SPEC

    TextFieldEntity     = EntityUtils.define_builder(*TextFieldSpec)
    NumericFieldEntity  = EntityUtils.define_builder(*NumericFieldSpec)
    DropdownFieldEntity = EntityUtils.define_builder(*DropdownFieldSpec)
    CheckboxFieldEntity = EntityUtils.define_builder(*CheckboxFieldSpec)
    DateFieldEntity     = EntityUtils.define_builder(*DateFieldSpec)

    def index
      @custom_fields = @current_community.custom_fields
      shapes = @current_community.shapes
      @price_in_use = shapes.any? { |s| s[:price_enabled] }
    end

    def new
      @custom_field = params[:field_type].constantize.new

      if params[:field_type] == 'CheckboxField'
        @min_option_count = 1
        @custom_field.options = [CustomFieldOption.new(sort_priority: 1)]
      else
        @min_option_count = 2
        @custom_field.options = [CustomFieldOption.new(sort_priority: 1), CustomFieldOption.new(sort_priority: 2)]
      end
      render layout: false
    end

    def edit
      @min_option_count = params[:field_type] == 'CheckboxField' ? 1 : 2
      @custom_field = @current_community.custom_fields.find(params[:id])
      render layout: false
    end

    def update
      @custom_field = @current_community.custom_fields.find(params[:id])

      # Hack for comma/dot issue. Consider creating an app-wide comma/dot handling mechanism
      params[:custom_field][:min] = ParamsService.parse_float(params[:custom_field][:min]) if params[:custom_field][:min].present?
      params[:custom_field][:max] = ParamsService.parse_float(params[:custom_field][:max]) if params[:custom_field][:max].present?

      custom_field_params = params[:custom_field].merge(
        sort_priority: @custom_field.sort_priority
      )

      custom_field_entity = build_custom_field_entity(@custom_field.type, custom_field_params)

      @custom_field.update(custom_field_entity)

    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_listings_listing_fields_path
    end

    def create
      params[:custom_field][:min] = ParamsService.parse_float(params[:custom_field][:min]) if params[:custom_field][:min].present?
      params[:custom_field][:max] = ParamsService.parse_float(params[:custom_field][:max]) if params[:custom_field][:max].present?

      custom_field_entity = build_custom_field_entity(params[:field_type], params[:custom_field])

      @custom_field = params[:field_type].constantize.new(custom_field_entity)
      @custom_field.entity_type = :for_listing
      @custom_field.community = @current_community

      success =
        if valid_categories?(@current_community, params[:custom_field][:category_attributes])
          @custom_field.save
        else
          false
        end

      raise "Listing field saving failed" unless success

    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_listings_listing_fields_path
    end

    def order
      sort_priorities = params[:order].each_with_index.map do |custom_field_id, index|
        [custom_field_id, index]
      end.inject({}) do |hash, ids|
        custom_field_id, sort_priority = ids
        hash.merge(custom_field_id.to_i => sort_priority)
      end

      @current_community.custom_fields.each do |custom_field|
        custom_field.update(:sort_priority => sort_priorities[custom_field.id])
      end

      head :ok
    end

    def destroy
      @custom_field = CustomField.find(params[:id])

      success = if custom_field_belongs_to_community?(@custom_field, @current_community)
                  @custom_field.destroy
                end

      raise "Field doesn't belong to current community" unless success
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_listings_listing_fields_path
    end

    private

    def valid_categories?(community, category_attributes)
      is_community_category = category_attributes.map do |category|
        community.categories.any? { |community_category| community_category.id == category[:category_id].to_i }
      end

      is_community_category.all?
    end

    def field_type_is_valid
      redirect_to admin2_listings_listing_fields_path unless CustomField::VALID_TYPES.include?(params[:field_type])
    end

    def build_custom_field_entity(type, params)
      params = params.respond_to?(:to_unsafe_hash) ? params.to_unsafe_hash : params
      case type
      when "TextField"
        TextFieldEntity.call(params)
      when "NumericField"
        NumericFieldEntity.call(params)
      when "DropdownField"
        DropdownFieldEntity.call(params)
      when "CheckboxField"
        CheckboxFieldEntity.call(params)
      when "DateField"
        DateFieldEntity.call(params)
      end
    end

  end
end
