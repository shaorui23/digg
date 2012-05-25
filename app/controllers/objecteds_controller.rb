class ObjectedsController < ApplicationController
  # GET /zsets
  # GET /zsets.json
  def index
    add_breadcrumb "Dashboard", "/redis_infos"
    add_breadcrumb "Redis Sorted Set", "/objecteds"
    if params[:query]
      @zsets = Objected.where("name like ?", "%"+params[:query]+"%").page params[:page]
    else
      @zsets = Objected.page params[:page]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @zsets }
    end
  end

  # GET /zsets/1
  # GET /zsets/1.json
  def show
    @zset = Objected.find(params[:id])

    add_breadcrumb "Dashboard", "/redis_infos"
    add_breadcrumb "Redis Sorted Set", "/objecteds"
    add_breadcrumb "#{@zset.redis_key}", "/objecteds/#{@zset.id}"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @zset }
    end
  end

  # GET /zsets/new
  # GET /zsets/new.json
  def new
    @zset = Objected.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @zset }
    end
  end

  # GET /zsets/1/edit
  def edit
    @zset = Objected.find(params[:id])
    add_breadcrumb "Dashboard", "/redis_infos"
    add_breadcrumb "Redis Sorted Set", "/objecteds"
    add_breadcrumb "#{@zset.redis_key}", "/objecteds/#{@zset.id}"
  end

  # POST /zsets
  # POST /zsets.json
  def create
    value = params[:objected].except "redis_value"
    @zset = Objected.new(value)

    respond_to do |format|
      if @zset.save
        Redis.current.zadd(@zset.redis_key, params[:objected][:score], params[:objected][:redis_value])
        
        format.html { redirect_to @zset, notice: 'Redis zset was successfully created.' }
        format.json { render json: @zset, status: :created, location: @objected }
      else
        format.html { render action: "new" }
        format.json { render json: @zset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /zsets/1
  # PUT /zsets/1.json
  def update
    @zset = Objected.find(params[:id])

    respond_to do |format|
      if @zset.update_attributes(params[:zset])
        format.html { redirect_to @zset, notice: 'Redis sorted set was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @zset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zsets/1
  # DELETE /zsets/1.json
  def destroy
    @zset = Objected.find(params[:id])
    @zset.destroy

    respond_to do |format|
      format.html { redirect_to objected_path }
      format.json { head :no_content }
    end
  end

  def add_redis_value
    @zset = Objected.find(params[:id]) 
    Redis.current.zadd(@zset.redis_key, params[:score], params[:value])

    respond_to do |format|
      format.html { redirect_to @zset, notice: 'Score and Value was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def destroy_redis_value
    @zset = Objected.find(params[:id]) 
    Redis.current.zrem(@zset.redis_key, params[:value])

    respond_to do |format|
      format.html { redirect_to edit_objected_path, notice: 'Value was successfully deleted.' }
      format.json { head :no_content }
    end
  end
end
