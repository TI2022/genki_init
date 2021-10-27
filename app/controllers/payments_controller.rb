class PaymentsController < ApplicationController
    #skip_before_action :authenticate_user!
    skip_before_action :authenticate_staff!
    before_action :set_q, only: [:index, :search]

  def pay
    orders = current_user.cart.orders.all
    subtotal = 0
    # @sumに合計金額を代入する
    orders.each do |order|
      subtotal += order.item.price*order.quantity
    end

    tax = (subtotal*0.10).round
    # 5000円以上のお買い上げで送料無料
    if subtotal >= 5000 || subtotal == 0
      shipping_fee = 0
    else
      shipping_fee = 500
    end
    total = subtotal+tax+shipping_fee

    payment = current_user.cart.payment.new
    payment.subtotal = subtotal
    payment.tax = tax
    payment.shipping_fee = shipping_fee
    payment.total = total
    payment.save

    Payjp.api_key = ENV["PAYJP_TEST_SECRET_KEY"]
    charge = Payjp::Charge.create(
    amount: total,
    card: params['payjp-token'],
    currency: 'jpy'
    )
    orders.destroy_all
    flash[:success] = "決済が完了しました。お買い上げ誠にありがとうございます。"
    redirect_to carts_path(current_user)
  end

  def index
    #@payments = current_user.cart.payment.order(id: "DESC")
    @payments = @q.result.page(params[:page]).per(5).order(id: "DESC") if current_user.cart.payment.present?
  end

  def show
    @payment = Payment.find(params[:id])
  end

  private

    def set_q
      @q = current_user.cart.payment.ransack(params[:q]) if current_user.cart.payment.present?
    end


end
