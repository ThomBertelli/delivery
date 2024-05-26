class ProductsController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!
  before_action :set_locale!


  def show
    respond_to do |format|
      format.html
      format.json { render :show, status: :ok, location: @product }
    end
  end

  def listing
    if !current_user.admin?
      redirect_to root_path, notice: "No permission for you! 🤪"
    end

    @products = Product.includes(:store)
  end

  def index
    respond_to do |format|
      format.json do
        if only_buyers! || store_belongs_to_current_user?
          page = params.fetch(:page,1)
          @products = Product.
            where(store_id: params[:store_id]).
            order(:title).
            page(page)
        end
      end
    end
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to product_url(@product), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_url(@product), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:store_id, :title, :price)
  end

  def store_belongs_to_current_user?
    @store = Store.find_by(id: params[:store_id])
    @store.user == current_user
  end

end
