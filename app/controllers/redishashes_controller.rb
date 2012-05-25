class RedishashesController < ApplicationController
  # GET /redishashes
  # GET /redishashes.json
  def index
    add_breadcrumb "Dashboard", "/redis_infos"
    add_breadcrumb "Redis Hash", "/redishashes"

    if params[:query]
      @redishashes = Redishash.where("name like ?", "%"+params[:query]+"%").page(params[:page])
    else
      @redishashes = Redishash.page params[:page]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @redishashes }
    end
  end

  # GET /redishashes/1
  # GET /redishashes/1.json
  def show
    @redishash = Redishash.find(params[:id])

    add_breadcrumb "Dashboard", "/redis_infos"
    add_breadcrumb "Redis Hash", "/redishashes"
    add_breadcrumb "#{@redishash.redis_key}", "/redishashes/#{@redishash.id}"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @redishash }
    end
  end

  # GET /redishashes/new
  # GET /redishashes/new.json
  def new
    @redishash = Redishash.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @redishash }
    end
  end

  # GET /redishashes/1/edit
  def edit
    @redishash = Redishash.find(params[:id])

    add_breadcrumb "Dashboard", "/redis_infos"
    add_breadcrumb "Redis Hash", "/redishashes"
    add_breadcrumb "#{@redishash.redis_key}", "/redishashes/#{@redishash.id}"
  end

  # POST /redishashes
  # POST /redishashes.json
  def create
    value = params[:redishash].except "redis_value"
    @redishash = Redishash.new(value)

    respond_to do |format|
      if @redishash.save
        
        # 容错性!
        # HSETNX nosql key-value-store redis
        params[:redishash][:redis_value].split("\r\n").each do |field_value|
          Redis.current.hsetnx(@redishash.redis_key, field_value.split(",")[0], field_value.split(",")[1])
        end

        format.html { redirect_to @redishash, notice: 'Redishash was successfully created.' }
        format.json { render json: @redishash, status: :created, location: @redishash }
      else
        format.html { render action: "new" }
        format.json { render json: @redishash.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /redishashes/1
  # PUT /redishashes/1.json
  def update
    @redishash = Redishash.find(params[:id])

    respond_to do |format|
      if @redishash.update_attributes(params[:redishash])
        @redishash.redis_value = params[:redishash][:redis_value]
        format.html { redirect_to @redishash, notice: 'Redishash was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @redishash.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /redishashes/1
  # DELETE /redishashes/1.json
  def destroy
    @redishash = Redishash.find(params[:id])
    Redis.current.del @redishash.redis_key
    @redishash.destroy

    respond_to do |format|
      format.html { redirect_to redishashes_url }
      format.json { head :no_content }
    end
  end

  def save_redis_value
    @redishash = Redishash.find(params[:id]) 
    Redis.current.hmset(@redishash.redis_key, params[:field], params[:value])

    render :text => params[:value] 
  end

  def add_redis_value
    @redishash = Redishash.find(params[:id]) 
    Redis.current.hsetnx(@redishash.redis_key, params[:field], params[:value])

    respond_to do |format|
      format.html { redirect_to edit_redishash_path, notice: 'Field and Value was successfully added.' }
      format.json { head :no_content }
    end
  end

  def destroy_redis_value
    @redishash = Redishash.find(params[:id]) 
    Redis.current.hdel(@redishash.redis_key, params[:field])

    respond_to do |format|
      format.html { redirect_to edit_redishash_path, notice: 'Field and Value were successfully deleted.' }
      format.json { head :no_content }
    end
  end
end
