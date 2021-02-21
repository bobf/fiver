# frozen_string_literal: true

class ErrorsController < ApplicationController
  def show
    @error = I18n.t("app.errors.#{params[:error]}")
  end
end
