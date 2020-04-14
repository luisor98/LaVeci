module Admin2::Listings
  class CategoriesController < Admin2::AdminBaseController

    def index
      @categories = @current_community.top_level_categories
                                      .includes(:translations, children: :translations)
    end

    def edit
      @category = @current_community.categories.find_by_url_or_id(params[:id])
      @shapes = @current_community.shapes
      @selected_shape_ids = CategoryListingShape.where(category_id: @category.id).map(&:listing_shape_id)
      render layout: false
    end

    def create
      @category = Category.new(category_params)
      @category.community = @current_community
      @category.parent_id = nil if params[:category][:parent_id].blank?
      @category.sort_priority = Admin::SortingService.next_sort_priority(@current_community.categories)
      selected_shape_ids = shape_ids_from_params(params)
      if @category.save
        update_category_listing_shapes(selected_shape_ids, @category)
      else
        raise 'Category saving failed'
      end
    rescue StandardError=> e
      flash[:error] = e.message
    ensure
      redirect_to admin2_listings_categories_path
    end

    def update
      @category = @current_community.categories.find_by_url_or_id(params[:id])
      selected_shape_ids = shape_ids_from_params(params)
      if @category.update(category_params)
        update_category_listing_shapes(selected_shape_ids, @category)
      else
        raise "Category saving failed"
      end
    rescue StandardError=> e
      flash[:error] = e.message
    ensure
      redirect_to admin2_listings_categories_path
    end

    def destroy
      @category = @current_community.categories.find_by_url_or_id(params[:id])
      @category.destroy
      redirect_to admin_categories_path
    end

    def new
      @category = Category.new
      @shapes = @current_community.shapes
      @selected_shape_ids = @shapes.map { |s| s[:id] }
      render layout: false
    end

    def order
      new_sort_order = params[:order].map(&:to_i).each_with_index
      order_categories!(new_sort_order)
      render body: nil, status: :ok
    end

    private

    def order_categories!(sort_priorities)
      base =  "sort_priority = CASE id\n"
      update_statements = sort_priorities.reduce(base) do |sql, (cat_id, priority)|
        sql + "WHEN #{cat_id} THEN #{priority}\n"
      end
      update_statements += "END"
      @current_community.categories.update_all(update_statements)
    end

    def category_params
      params.require(:category)
            .slice(:parent_id, :translation_attributes, :sort_priority, :url, :basename)
            .permit!
    end

    def shape_ids_from_params(params)
      params[:category][:listing_shapes].map { |s_param| s_param[:listing_shape_id].to_i }
    end

    def update_category_listing_shapes(shape_ids, category)
      selected_shapes = @current_community.shapes.select { |s| shape_ids.include? s[:id] }

      raise ArgumentError.new("No shapes selected for category #{category.id}, shape_ids: #{shape_ids}") if selected_shapes.empty?

      CategoryListingShape.where(category_id: category.id).delete_all

      selected_shapes.each { |s|
        CategoryListingShape.create!(category_id: category.id, listing_shape_id: s[:id])
      }
    end

  end
end
