class SessionsController < ApplicationController
  def new
    redirect_to '/auth/google_oauth2'
  end

  def create
    # Lấy thông tin user từ OAuth
    auth = request.env['omniauth.auth']
    session[:user_id] = auth.uid
    session[:access_token] = auth.credentials.token
    session[:refresh_token] = auth.credentials.refresh_token
    redirect_to update_sheet_path, notice: 'Đăng nhập thành công!'
  rescue StandardError => e
    redirect_to root_path, alert: "Đăng nhập thất bại: #{e.message}"
  end

  def destroy
    session[:user_id] = nil
    session[:access_token] = nil
    session[:refresh_token] = nil
    redirect_to root_path, notice: 'Đã đăng xuất!'
  end
end
