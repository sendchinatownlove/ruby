class NonprofitsController < ApplicationController
  before_action :set_nonprofit, only: [:show, :update, :destroy]

  # GET /nonprofits
  def index
    @nonprofits = Nonprofit.all

    render json: @nonprofits
  end

  # GET /nonprofits/1
  def show
    render json: @nonprofit
  end

  # POST /nonprofits
  def create
    @nonprofit = Nonprofit.new(nonprofit_params)

    if @nonprofit.save
      render json: @nonprofit, status: :created, location: @nonprofit
    else
      render json: @nonprofit.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /nonprofits/1
  def update
    if @nonprofit.update(nonprofit_params)
      render json: @nonprofit
    else
      render json: @nonprofit.errors, status: :unprocessable_entity
    end
  end

  # DELETE /nonprofits/1
  def destroy
    @nonprofit.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nonprofit
      @nonprofit = Nonprofit.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def nonprofit_params
      params.require(:nonprofit).permit(:name, :logo_image_url, :contact_id, :fee_id)
    end
end
