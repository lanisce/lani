# Carts controller for Medusa e-commerce integration
class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :add_item, :update_item, :remove_item]
  before_action :set_cart, only: [:show, :add_item, :update_item, :remove_item, :checkout]
  
  def show
    @cart_items = @cart.cart_items.includes(:product)
  end
  
  def add_item
    @product = Product.find(params[:product_id])
    @variant_id = params[:variant_id] || @product.medusa_id
    @quantity = params[:quantity]&.to_i || 1
    
    begin
      @cart.add_product(@product, @quantity, @variant_id)
      @cart.sync_to_medusa!
      
      respond_to do |format|
        format.html { redirect_to cart_path(@cart), notice: 'Item added to cart successfully.' }
        format.json { 
          render json: { 
            success: true, 
            message: 'Item added to cart',
            cart_count: @cart.item_count,
            cart_total: @cart.formatted_total
          }
        }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("cart_count", partial: "shared/cart_count", locals: { cart: @cart }),
            turbo_stream.replace("cart_total", partial: "shared/cart_total", locals: { cart: @cart }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash_message", 
                               locals: { type: "notice", message: "Item added to cart successfully." })
          ]
        }
      end
    rescue => e
      Rails.logger.error "Failed to add item to cart: #{e.message}"
      
      respond_to do |format|
        format.html { redirect_to product_path(@product), alert: "Failed to add item to cart: #{e.message}" }
        format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.prepend("flash_messages", 
                                                   partial: "shared/flash_message", 
                                                   locals: { type: "alert", message: "Failed to add item: #{e.message}" })
        }
      end
    end
  end
  
  def update_item
    @cart_item = @cart.cart_items.find(params[:item_id])
    @quantity = params[:quantity].to_i
    
    begin
      if @quantity > 0
        @cart_item.update!(quantity: @quantity)
      else
        @cart_item.destroy
      end
      
      @cart.sync_to_medusa!
      
      respond_to do |format|
        format.html { redirect_to cart_path(@cart), notice: 'Cart updated successfully.' }
        format.json { 
          render json: { 
            success: true, 
            cart_count: @cart.item_count,
            cart_total: @cart.formatted_total,
            item_total: @cart_item.formatted_total
          }
        }
        format.turbo_stream {
          if @quantity > 0
            render turbo_stream: [
              turbo_stream.replace("cart_item_#{@cart_item.id}", 
                                 partial: "carts/cart_item", locals: { cart_item: @cart_item }),
              turbo_stream.replace("cart_count", partial: "shared/cart_count", locals: { cart: @cart }),
              turbo_stream.replace("cart_total", partial: "shared/cart_total", locals: { cart: @cart })
            ]
          else
            render turbo_stream: [
              turbo_stream.remove("cart_item_#{@cart_item.id}"),
              turbo_stream.replace("cart_count", partial: "shared/cart_count", locals: { cart: @cart }),
              turbo_stream.replace("cart_total", partial: "shared/cart_total", locals: { cart: @cart })
            ]
          end
        }
      end
    rescue => e
      Rails.logger.error "Failed to update cart item: #{e.message}"
      
      respond_to do |format|
        format.html { redirect_to cart_path(@cart), alert: "Failed to update cart: #{e.message}" }
        format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.prepend("flash_messages", 
                                                   partial: "shared/flash_message", 
                                                   locals: { type: "alert", message: "Update failed: #{e.message}" })
        }
      end
    end
  end
  
  def remove_item
    @cart_item = @cart.cart_items.find(params[:item_id])
    
    begin
      @cart_item.destroy
      @cart.sync_to_medusa!
      
      respond_to do |format|
        format.html { redirect_to cart_path(@cart), notice: 'Item removed from cart.' }
        format.json { 
          render json: { 
            success: true, 
            cart_count: @cart.item_count,
            cart_total: @cart.formatted_total
          }
        }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.remove("cart_item_#{@cart_item.id}"),
            turbo_stream.replace("cart_count", partial: "shared/cart_count", locals: { cart: @cart }),
            turbo_stream.replace("cart_total", partial: "shared/cart_total", locals: { cart: @cart }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash_message", 
                               locals: { type: "notice", message: "Item removed from cart." })
          ]
        }
      end
    rescue => e
      Rails.logger.error "Failed to remove cart item: #{e.message}"
      
      respond_to do |format|
        format.html { redirect_to cart_path(@cart), alert: "Failed to remove item: #{e.message}" }
        format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
      end
    end
  end
  
  def checkout
    return redirect_to cart_path(@cart), alert: 'Cart is empty.' if @cart.empty?
    
    begin
      @order = @cart.complete_order!
      redirect_to order_path(@order), notice: 'Order placed successfully!'
    rescue => e
      Rails.logger.error "Checkout failed: #{e.message}"
      redirect_to cart_path(@cart), alert: "Checkout failed: #{e.message}"
    end
  end
  
  private
  
  def set_project
    @project = current_user.projects.find(params[:project_id]) if params[:project_id].present?
  end
  
  def set_cart
    @cart = Cart.current_for_user(current_user, @project)
  end
end
