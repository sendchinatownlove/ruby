class MenuItemsController < ApplicationController
  before_action :set_seller
  before_action :set_seller_menu_item, only: [:update, :destroy]

  # GET /sellers/:seller_id/menu_items
  def index
    json_response(@seller.menu_items)
  end

  # POST /sellers/:seller_id/menu_items
  def create
    json_response(@seller.menu_items.create!(menu_item_params), :created)
  end

  # PUT /sellers/:seller_id/menu_items/:id
  def update
    @menu_item.update(menu_item_params)
    json_response(@menu_item)
  end

  # DELETE /sellers/:seller_id/menu_items/:id
  def destroy
    json_response(@menu_item.destroy)
  end

  private

  def menu_item_params
    update_params
  end

  def update_params
    params.permit(
      :name,
      :description,
      :amount,
      :image_url
    )
  end

  def set_seller
    @seller = Seller.find_by!(seller_id: params[:seller_id])
  end

  def set_seller_menu_item
    @menu_item = @seller.menu_items.find_by!(id: params[:id]) if @seller
  end
end
