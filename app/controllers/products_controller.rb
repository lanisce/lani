# Products controller for Medusa e-commerce integration
class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:index, :show]
  before_action :set_product, only: [:show]
  
  def index
    @products = Product.published
    @products = @products.by_collection(params[:collection]) if params[:collection].present?
    @products = @products.search(params[:search]) if params[:search].present?
    @products = @products.includes(:project).page(params[:page]).per(12)
    
    @collections = Product.published.pluck(:collection_title).compact.uniq
    @current_collection = params[:collection]
    @search_query = params[:search]
    
    # Get current user's cart for quick add functionality
    @current_cart = Cart.current_for_user(current_user, @project)
  end
  
  def show
    @variants = @product.available_variants
    @current_cart = Cart.current_for_user(current_user, @project)
    @related_products = Product.published
                              .where.not(id: @product.id)
                              .by_collection(@product.collection_title)
                              .limit(4)
  end
  
  def sync
    authorize_admin!
    
    begin
      Product.sync_from_medusa
      redirect_to products_path, notice: 'Products synchronized successfully from Medusa.'
    rescue => e
      Rails.logger.error "Product sync failed: #{e.message}"
      redirect_to products_path, alert: "Sync failed: #{e.message}"
    end
  end
  
  private
  
  def set_project
    @project = current_user.projects.find(params[:project_id]) if params[:project_id].present?
  end
  
  def set_product
    @product = Product.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: 'Product not found.'
  end
  
  def authorize_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user.admin?
  end
end
