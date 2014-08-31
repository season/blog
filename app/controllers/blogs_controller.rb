#encoding: utf-8
class BlogsController < ApplicationController
  before_filter :require_login, only: [:set, :upload_img]

  def index

  end

  def set

  end

  def set_userinfo
    user = User.find @current_user.id
    user.nick_name = params[:user][:nick_name] if params[:user][:nick_name].present?
    #begin
      if params[:user][:avatar].present?
        upload_info = upload_picture params[:user][:avatar]
        user.avatar = "/images/#{upload_info[:real_file_name]}"
      end
    #end
    if user.save
      redirect_to set_blogs_path
    else
      flash.now[:error] = '修改用户信息失败'
      render 'set'
    end
  end

  def upload_img
    @result = {status: false, message: '', text_id: params[:upload][:text_id] || ''}
    begin
      if params[:upload].present? && params[:upload][:img].present? && remotipart_submitted?
        upload_info = upload_picture params[:upload][:img]
        @result[:status] = true
        @result[:message] = "![#{upload_info[:file_name]}](/images/#{upload_info[:real_file_name]})"
      end
    rescue UploadException => e
      @result[:message] = e.message
    end
    respond_to do |format|
      format.js
    end
  end

  protected

  def upload_picture(file)
    upload_path = File.join Rails.root, 'public/images'
    upload = SimpleFileupload.new upload_path:upload_path, max_size: 1024*1024*2, type: 'image'
    upload_info = upload.upload file
  end
end