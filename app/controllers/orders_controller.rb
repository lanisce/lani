# Orders controller for Medusa e-commerce integration
class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:index, :show]
  before_action :set_order, only: [:show, :cancel, :request_refund]
  
  def index
    @orders = current_user.orders.recent.includes(:order_items, :products)
    @orders = @orders.for_project(@project) if @project
    @orders = @orders.by_status(params[:status]) if params[:status].present?
    @orders = @orders.page(params[:page]).per(10)
    
    @status_counts = {
      all: current_user.orders.count,
      pending: current_user.orders.pending.count,
      completed: current_user.orders.completed.count,
      canceled: current_user.orders.canceled.count
    }
    
    @current_status = params[:status] || 'all'
  end
  
  def show
    @order_items = @order.order_items.includes(:product)
  end
  
  def cancel
    authorize_order_action!
    
    if @order.cancel!
      redirect_to order_path(@order), notice: 'Order canceled successfully.'
    else
      redirect_to order_path(@order), alert: 'Unable to cancel this order.'
    end
  end
  
  def request_refund
    authorize_order_action!
    
    reason = params[:reason]
    
    if @order.request_refund!(reason)
      redirect_to order_path(@order), notice: 'Refund request submitted successfully.'
    else
      redirect_to order_path(@order), alert: 'Unable to request refund for this order.'
    end
  end
  
  def sync
    authorize_admin!
    
    begin
      Order.sync_from_medusa(current_user)
      redirect_to orders_path, notice: 'Orders synchronized successfully from Medusa.'
    rescue => e
      Rails.logger.error "Order sync failed: #{e.message}"
      redirect_to orders_path, alert: "Sync failed: #{e.message}"
    end
  end
  
  private
  
  def set_project
    @project = current_user.projects.find(params[:project_id]) if params[:project_id].present?
  end
  
  def set_order
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: 'Order not found.'
  end
  
  def authorize_order_action!
    unless @order.user == current_user || current_user.admin?
      redirect_to orders_path, alert: 'Access denied.'
    end
  end
  
  def authorize_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user.admin?
  end
end
