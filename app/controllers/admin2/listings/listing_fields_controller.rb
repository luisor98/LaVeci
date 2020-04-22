module Admin2::Listings
  class ListingFieldsController < Admin2::AdminBaseController

    def index
      @custom_fields = @current_community.custom_fields
      shapes = @current_community.shapes
      @price_in_use = shapes.any? { |s| s[:price_enabled] }
    end

    def create

    end

  end
end
