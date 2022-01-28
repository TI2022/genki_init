class ReviewsController < ApplicationController
  skip_before_action :authenticate_staff!
  
  def new
    @reservation = Reservation.find(params[:reservation_id])
    # @reservation = Reservation.where(status: :completed, guest_id: current_user.id).order(id: :desc).first
    @review = Review.new
  end
  
  def create
    @reservation = Reservation.find(params[:reservation_id])
    @review = @reservation.reviews.build(review_params)
    @review.user_id = current_user.id
    if @reservation.is_review_exists == 1
      @reservation.is_review_exists = 2
      @reservation.save
    end
    if @review.save
      redirect_to reservation_reviews_url
      flash[:success] = "投稿に成功しました。"
    else
      render :new
    end
  end
  
  def edit
    @reservation = Reservation.find(params[:reservation_id])
    @review = Review.find(params[:id])
  end
  
  def update
    @review = Review.find(params[:id])
    if @review.update(review_params)
      redirect_to reservation_reviews_url
      flash[:success] = "編集に成功しました。"
    else
      render :edit
      flash[:danger] = "更新に失敗しました。"
    end
  end

  def index
    @reservation = Reservation.where(is_review_exists: 2, guest_id: current_user.id) #投稿したユーザーの分だけを表示させる
    @reservation_id = Reservation.find(params[:reservation_id])
    @reviews = Review.includes(:reservation).where(user_id: current_user.id).page(params[:page]).per(10).order(created_at: "ASC")
    @review_total_score = @reviews.average(:total_score).round(1)
    @review_menu_score = @reviews.average(:menu_score).round(1)
    @review_customer_score = @reviews.average(:customer_score).round(1)
    @review_atmosphere_score = @reviews.average(:atmosphere_score).round(1)
    # @review_answers = ReviewAnswer.new
    # @staff = Staff.all
  end

  def show
    @reservation = Reservation.find(params[:reservation_id])
    # @reservation = Reservation.where(is_review_exists: 2)
    @review = Review.find(params[:id])    
  end

  def destroy
    @review = Review.find(params[:id])
    if @review.destroy
      redirect_to users_account_url
      flash[:success] = "レビューを削除しました。"
    end
  end

  private
    def review_params
      params.require(:review).permit(:reservation_id, :title, :content, :total_score, :menu_score, :customer_score, :atmosphere_score, :review_exists)
    end

end