class StringlistsController < ApplicationController

  def query params
    Redis.current.keys params[:string]
  end
  # GET /stringlists
  # GET /stringlists.json
  def index
    add_breadcrumb "Home", "/redis_infos"
    add_breadcrumb "String", "/stringlists"
    @stringlists = Stringlist.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stringlists }
    end
  end

  # GET /stringlists/1
  # GET /stringlists/1.json
  def show
    @stringlist = Stringlist.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stringlist }
    end
  end

  # GET /stringlists/new
  # GET /stringlists/new.json
  def new
    @stringlist = Stringlist.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @stringlist }
    end
  end

  # GET /stringlists/1/edit
  def edit
    @stringlist = Stringlist.find(params[:id])
  end

  # POST /stringlists
  # POST /stringlists.json
  def create
    @stringlist = Stringlist.new(params[:stringlist])

    respond_to do |format|
      if @stringlist.save
        @stringlist.redis_value = params[:stringlist][:redis_value]
        format.html { redirect_to @stringlist, notice: 'Redis String was successfully created.' }
        format.json { render json: @stringlist, status: :created, location: @stringlist }
      else
        format.html { render action: "new" }
        format.json { render json: @stringlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stringlists/1
  # PUT /stringlists/1.json
  def update
    @stringlist = Stringlist.find(params[:id])

    respond_to do |format|
      if @stringlist.update_attributes(params[:stringlist])
        format.html { redirect_to @stringlist, notice: 'Stringlist was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @stringlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stringlists/1
  # DELETE /stringlists/1.json
  def destroy
    @stringlist = Stringlist.find(params[:id])
    @stringlist.destroy

    respond_to do |format|
      format.html { redirect_to stringlists_url }
      format.json { head :no_content }
    end
  end
end
