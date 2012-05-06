class RecordsController < ApplicationController
  def index
    @sets = Redisset.all
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sets }
    end
  end

  def show
    @redisset = Redisset.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @redisset }
    end
  end

  def new
    @redisset = Redisset.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @redisset }
    end
  end

  def edit
    @set = Redisset.find(params[:id])
  end

  def create
    value = params[:redisset].except "redis_value"
    @redisset = Redisset.new(value)

    respond_to do |format|
      if @redisset.save
        Redis.current.sadd(@redisset.redis_key, params[:redisset][:redis_value])

        format.html { redirect_to record_path(@redisset), notice: 'Redis set was successfully created.' }
        format.json { render json: @redisset, status: :created, location: @redisset }
      else
        format.html { render action: "new" }
        format.json { render json: @redisset.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @redisset = Redisset.find(params[:id])

    respond_to do |format|
      if @redisset.update_attributes(params[:redisset])
        @redisset.redis_value = params[:redisset][:redis_value]
        format.html { redirect_to record_path(@redisset), notice: 'set was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @redisset.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @set = Redisset.find(params[:id])
    Redis.current.del @set.redis_key
    @set.destroy

    respond_to do |format|
      format.html { redirect_to records_path }
      format.json { head :no_content }
    end
  end
  
end
