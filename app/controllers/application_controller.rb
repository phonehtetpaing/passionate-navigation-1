# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    render json: { message: "You are not authorized to do that" }, status: :unauthorized
  end

  def pundit_user
    header = request.headers["Authorization"]
    header = header.split(" ").last if header
    begin
      decoded = JsonWebToken.decode(header)
      return User.find(decoded["id"])
    rescue ActiveRecord::RecordNotFound
      render json: { message: "You are not authorized" }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { message: "Unauthorized access" }, status: :unauthorized
    end
  end

  def shown_attributes(user)
    {
      id: user.id,
      email: user.email
    }
  end

  def find_error(resource_type)
    render json: { message: "Cannot find #{resource_type}" }, status: 404
  end

  def process_error(resource, message)
    render json: { message: message, errors: resource.errors }, status: :unprocessable_entity
  end

  def action_success(message, status_code = nil)
    status_code ||= :accepted
    render json: { message: message },
           status: status_code
  end
end
