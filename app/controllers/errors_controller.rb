# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_before_action :fetch_rabbitmq_state

  def show
    @error = I18n.t("app.errors.#{params[:error]}", message: params[:message])
  end
end
