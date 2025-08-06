class FramesController < ApplicationController
  # POST /frames
  def create
    ActiveRecord::Base.transaction do
      builder = FrameBuilder.new(**frame_builder_params)
      frame   = builder.call

      unless frame.persisted?
        raise ActiveRecord::Rollback
      end

      create_circles_for(frame) if circles_params.present?

      render json: frame, status: :created and return
    rescue => e
      render json: { errors: e.message }, status: :unprocessable_entity
    end
  end

  # POST /frames/:id/circles
  def create_circle
    frame = Frame.find(params[:id])
    factory = RGeo::Cartesian.simple_factory(srid: 0)
    circle = frame.circles.build(
      radius: circle_params[:radius].to_f,
      center: factory.point(circle_params[:center_x].to_f, circle_params[:center_y].to_f)
    )

    if circle.save
      render json: circle, status: :created
    else
      render json: { errors: circle.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /frames/:id
  def show
    frame = Frame.find(params[:id])
    stats = FrameStats.new(frame).call
    render json: stats
  end

  # DELETE /frames/:id
  def destroy
    frame = Frame.find(params[:id])

    if frame.circles.exists?
      render json: { errors: ["Cannot delete frame with associated circles"] }, status: :unprocessable_entity
    else
      frame.destroy
      head :no_content
    end
  end

  private

  def create_circles_for(frame)
    factory = RGeo::Cartesian.simple_factory(srid: 0)
    circles_params.each do |attrs|
      point = factory.point(attrs[:center_x].to_f, attrs[:center_y].to_f)
      frame.circles.create!(radius: attrs[:radius].to_f, center: point)
    end
  end

  def circle_params
    params.require(:circle).permit(:center_x, :center_y, :radius)
  end

  def circles_params
    params[:circles]&.map do |c|
      c.permit(:center_x, :center_y, :radius).to_h.symbolize_keys
    end || []
  end

  def frame_builder_params
    attrs = params.require(:frame).permit(:board_id, :center_x, :center_y, :width, :height)
                 .to_h
                 .deep_symbolize_keys
    attrs[:board_id] ||= Board.find_by!(name: "main").id
    attrs
  end
end
