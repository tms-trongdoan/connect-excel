class SheetsController < ApplicationController
  require 'google/apis/sheets_v4'
  require 'cgi'

  def new
  end

  def auth
    if request.get?
      if session[:sheet_id].present? && session[:worksheet_name].present?
        redirect_to '/auth/google_oauth2'
      else
        redirect_to new_sheet_path, alert: 'Vui lòng nhập thông tin Sheet ID và tên worksheet!'
      end
    elsif request.post?
      if params[:sheet_id].present? && params[:worksheet_name].present?
        session[:sheet_id] = params[:sheet_id]
        session[:worksheet_name] = params[:worksheet_name]
        redirect_to '/auth/google_oauth2'
      else
        redirect_to new_sheet_path, alert: 'Vui lòng nhập đầy đủ thông tin!'
      end
    end
  rescue StandardError => e
    redirect_to new_sheet_path, alert: "Lỗi khi xử lý yêu cầu: #{e.message}"
  end

  def oauth_redirect
    google_oauth_url = build_google_oauth_url
    response.headers['Turbo-Visit-Control'] = 'reload'
    redirect_to google_oauth_url, allow_other_host: true, status: :see_other
  end

  def callback
    if params[:code].present?
      token_response = exchange_code_for_token(params[:code])
      
      if token_response
        session[:access_token] = token_response['access_token']
        session[:refresh_token] = token_response['refresh_token']
        redirect_to update_sheet_path
      else
        redirect_to new_sheet_path, alert: 'Không thể lấy access token!'
      end
    else
      redirect_to new_sheet_path, alert: 'Xác thực thất bại!'
    end
  rescue StandardError => e
    redirect_to new_sheet_path, alert: "Lỗi xác thực: #{e.message}"
  end

  def update
    unless session[:access_token] && session[:sheet_id] && session[:worksheet_name]
      redirect_to new_sheet_path, alert: 'Xác thực hoặc thông tin sheet chưa sẵn sàng!'
      return
    end

    begin
      service = Google::Apis::SheetsV4::SheetsService.new
      service.authorization = Google::Auth::UserRefreshCredentials.new(
        client_id: ENV['GOOGLE_CLIENT_ID'],
        client_secret: ENV['GOOGLE_CLIENT_SECRET'],
        scope: ['https://www.googleapis.com/auth/spreadsheets'],
        access_token: session[:access_token],
        refresh_token: session[:refresh_token]
      )

      sheet_id = session[:sheet_id]
      worksheet_name = session[:worksheet_name]
      
      users = User.all
      range = "#{worksheet_name}!A1:C#{users.count + 1}"

      service.clear_values(sheet_id, range)
      
      data = [['Tên', 'Tuổi', 'Email']]
      users.each do |user|
        data << [user.name, user.age, user.email]
      end
      
      value_range = Google::Apis::SheetsV4::ValueRange.new(values: data)
      service.update_spreadsheet_value(sheet_id, range, value_range, value_input_option: 'RAW')

      redirect_to new_sheet_path, notice: "Đã xuất #{users.count} người dùng vào Google Sheets!"
    rescue Google::Apis::AuthorizationError
      redirect_to new_sheet_path, alert: 'Phiên hết hạn, thử lại!'
    rescue StandardError => e
      redirect_to new_sheet_path, alert: "Lỗi: #{e.message}"
    end
  end

  private

  def exchange_code_for_token(code)
    require 'net/http'
    require 'json'
    
    uri = URI('https://oauth2.googleapis.com/token')
    
    params = {
      code: code,
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      redirect_uri: ENV['GOOGLE_REDIRECT_URI'],
      grant_type: 'authorization_code'
    }
    
    response = Net::HTTP.post_form(uri, params)
    
    if response.code == '200'
      JSON.parse(response.body)
    else
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Token exchange error: #{e.message}"
    nil
  end

  def build_google_oauth_url
    client_id = ENV['GOOGLE_CLIENT_ID']
    redirect_uri = ENV['GOOGLE_REDIRECT_URI']
    scope = 'https://www.googleapis.com/auth/spreadsheets'
    
    params = {
      response_type: 'code',
      client_id: client_id,
      redirect_uri: redirect_uri,
      scope: scope,
      access_type: 'offline',
      prompt: 'consent'
    }
    
    query_string = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
    "https://accounts.google.com/o/oauth2/auth?#{query_string}"
  end
end
