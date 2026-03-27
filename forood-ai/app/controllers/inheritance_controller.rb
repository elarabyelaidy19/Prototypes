class InheritanceController < ApplicationController
  allow_unauthenticated_access

  def new
  end

  def calculate
    hp = heirs_params
    Rails.logger.info "[Forood] Raw heirs params: #{hp.inspect}"

    calculator = Inheritance::Calculator.new(
      deceased_gender: params[:deceased_gender],
      estate_amount: params[:estate_amount],
      heirs: hp
    )

    @result = calculator.calculate

    render partial: "result", locals: { result: @result }
  rescue ArgumentError => e
    render partial: "error", locals: { message: e.message }
  end

  private

  def heirs_params
    permitted = %i[
      husband wife father mother grandfather grandmother
      son daughter sons_son sons_daughter
      full_brother full_sister paternal_brother paternal_sister
      maternal_brother maternal_sister
    ]
    params.fetch(:heirs, {}).permit(*permitted).to_h
  end
end
