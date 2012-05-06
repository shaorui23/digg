class ProductsController < ApplicationController
  # GET /products
  # GET /products.json
  def index
    add_breadcrumb "Home", "/redis_infos"
    add_breadcrumb "Redis List", "/products"
    
    @products = Product.page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # Redis_value必须要在product创建之后commit，但之前必须过滤掉改值，因为会执行redis_value的写操作
  def create
    value = params[:product].except "redis_value"
    @product = Product.new(value)

    respond_to do |format|
      if @product.save

        # Redis 执行原子性操作，事务
        Redis.current.multi
        params[:product][:redis_value].split(",").each do |v|
          Redis.current.rpush(@product.redis_key, v)
        end
        Redis.current.exec
        # 结束事务操作

        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
        @product.redis_value = params[:product][:redis_value]
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # 对非空列表进行 LSET
  #redis> LPUSH job "cook food"
  #(integer) 1
  #redis> LRANGE job 0 0
  #1) "cook food"
  #redis> LSET job 0 "play game"
  #OK
  #redis> LRANGE job  0 0
  #1) "play game"
  #
  def edit_redis_value
    @product = Product.find(params[:id]) 
    @value = @product.redis_value.split(",")[params[:index].to_i]
   #key = Product.find(params[:id]).redis_key
   #Redis.current.lset(key, params[:index], params[:value])
  end

  def save_redis_value
    @product = Product.find(params[:id]) 
    Redis.current.lset(@product.redis_key, params[:index], params[:value])

    render :text => params[:value] 
  end

  def add_redis_value
    @product = Product.find(params[:id]) 
    Redis.current.rpush(@product.redis_key, params[:value])

    respond_to do |format|
      format.html { redirect_to @product, notice: 'Value was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def destroy_redis_value
    @product = Product.find(params[:id]) 
    Redis.current.lrem(@product.redis_key, params[:index], params[:value])

    respond_to do |format|
      format.html { redirect_to edit_product_path, notice: 'Value was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product = Product.find(params[:id])
    Redis.current.del @product.redis_key
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end
end
