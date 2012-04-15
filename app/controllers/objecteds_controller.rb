class ObjectedsController < ApplicationController
  # GET /objecteds
  # GET /objecteds.json
  def index
    @objecteds = Objected.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @objecteds }
    end
  end

  # GET /objecteds/1
  # GET /objecteds/1.json
  def show
    @objected = Objected.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @objected }
    end
  end

  # GET /objecteds/new
  # GET /objecteds/new.json
  def new
    @objected = Objected.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @objected }
    end
  end

  # GET /objecteds/1/edit
  def edit
    @objected = Objected.find(params[:id])
  end

  # POST /objecteds
  # POST /objecteds.json
  def create
    @objected = Objected.new(params[:objected])

    respond_to do |format|
      if @objected.save
        format.html { redirect_to @objected, notice: 'Objected was successfully created.' }
        format.json { render json: @objected, status: :created, location: @objected }
      else
        format.html { render action: "new" }
        format.json { render json: @objected.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /objecteds/1
  # PUT /objecteds/1.json
  def update
    @objected = Objected.find(params[:id])

    respond_to do |format|
      if @objected.update_attributes(params[:objected])
        format.html { redirect_to @objected, notice: 'Objected was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @objected.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /objecteds/1
  # DELETE /objecteds/1.json
  def destroy
    @objected = Objected.find(params[:id])
    @objected.destroy

    respond_to do |format|
      format.html { redirect_to objecteds_url }
      format.json { head :no_content }
    end
  end
end
