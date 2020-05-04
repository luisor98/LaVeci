module Admin2::Users
  class UserFieldsController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    def new
      @service.new_custom_field
      render layout: false
    end

    def edit
      @service.find_custom_field
      render layout: false
    end

    def update
      @service.update
    ensure
      redirect_to admin2_user_user_fields_path
    end

    def create
      success = @service.create
      unless success
        flash[:error] = I18n.t('admin.person_custom_fields.saving_failed')
      end
    ensure
      redirect_to admin2_user_user_fields_path
    end

    def destroy
      @service.destroy
      redirect_to admin_person_custom_fields_path
    end

    def order
      @service.order
      render body: nil, status: :ok
    end

    private

    def set_service
      @service = Admin::PersonCustomFieldsService.new(
        community: @current_community,
        params: params)
    end

  end
end
