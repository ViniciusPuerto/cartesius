class CirclesController < ApplicationController
  # GET /circles?center_x=&center_y=&radius=&frame_id=
  def index
    required = %i[center_x center_y radius]
    unless required.all? { |k| params.key?(k) }
      return render json: { errors: ["center_x, center_y and radius are required"] }, status: :unprocessable_entity
    end

    factory = RGeo::Cartesian.simple_factory(srid: 0)
    point   = factory.point(params[:center_x].to_f, params[:center_y].to_f)
    radius  = params[:radius].to_f

    circles = Circle.where("ST_DWithin(center, ST_GeomFromText(?, 0), ?)", point.as_text, radius)
    circles = circles.where(frame_id: params[:frame_id]) if params[:frame_id].present?

    render json: circles, status: :ok
  end

  # PUT /circles/:id
  def update
    circle = Circle.find(params[:id])
    factory = RGeo::Cartesian.simple_factory(srid: 0)

    if circle_params.key?(:center_x) && circle_params.key?(:center_y)
      circle.center = factory.point(circle_params[:center_x].to_f, circle_params[:center_y].to_f)
    end
    circle.radius = circle_params[:radius].to_f if circle_params.key?(:radius)

    if circle.save
      render json: circle, status: :ok
    else
      render json: { errors: circle.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /circles/:id
  def destroy
    circle = Circle.find(params[:id])
    circle.destroy
    head :no_content
  end

  private

  def circle_params
    params.require(:circle).permit(:center_x, :center_y, :radius)
  end
end
