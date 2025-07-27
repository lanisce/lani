class ProjectFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :authorize_project_access!

  def index
    @files = []
    @nextcloud_configured = NextcloudService.configured?
    
    if @nextcloud_configured
      begin
        @nextcloud = NextcloudService.new
        
        # Ensure project folder exists
        folder_result = @nextcloud.create_project_folder(@project)
        
        if folder_result[:success]
          # List files in the project folder
          files_result = @nextcloud.list_project_files(@project)
          @files = files_result[:files] if files_result[:success]
          @folder_web_url = folder_result[:web_url]
        else
          flash.now[:alert] = "Unable to access project files: #{folder_result[:error]}"
        end
      rescue => e
        Rails.logger.error "Nextcloud error: #{e.message}"
        flash.now[:alert] = "File service temporarily unavailable"
      end
    end
  end

  def upload
    unless NextcloudService.configured?
      redirect_to project_files_path(@project), alert: "File service not configured"
      return
    end

    uploaded_file = params[:file]
    unless uploaded_file
      redirect_to project_files_path(@project), alert: "No file selected"
      return
    end

    begin
      @nextcloud = NextcloudService.new
      
      result = @nextcloud.upload_file(@project, uploaded_file.original_filename, uploaded_file.read)
      
      if result[:success]
        redirect_to project_files_path(@project), notice: "File uploaded successfully"
      else
        redirect_to project_files_path(@project), alert: "Upload failed: #{result[:error]}"
      end
    rescue => e
      Rails.logger.error "File upload error: #{e.message}"
      redirect_to project_files_path(@project), alert: "Upload failed"
    end
  end

  def download
    unless NextcloudService.configured?
      redirect_to project_files_path(@project), alert: "File service not configured"
      return
    end

    filename = params[:filename]
    unless filename
      redirect_to project_files_path(@project), alert: "File not specified"
      return
    end

    begin
      @nextcloud = NextcloudService.new
      
      result = @nextcloud.download_file(@project, filename)
      
      if result[:success]
        send_data result[:content], 
                  filename: filename,
                  type: result[:content_type] || 'application/octet-stream'
      else
        redirect_to project_files_path(@project), alert: "Download failed: #{result[:error]}"
      end
    rescue => e
      Rails.logger.error "File download error: #{e.message}"
      redirect_to project_files_path(@project), alert: "Download failed"
    end
  end

  def destroy
    unless NextcloudService.configured?
      redirect_to project_files_path(@project), alert: "File service not configured"
      return
    end

    filename = params[:filename]
    unless filename
      redirect_to project_files_path(@project), alert: "File not specified"
      return
    end

    begin
      @nextcloud = NextcloudService.new
      
      result = @nextcloud.delete_file(@project, filename)
      
      if result[:success]
        redirect_to project_files_path(@project), notice: "File deleted successfully"
      else
        redirect_to project_files_path(@project), alert: "Delete failed: #{result[:error]}"
      end
    rescue => e
      Rails.logger.error "File delete error: #{e.message}"
      redirect_to project_files_path(@project), alert: "Delete failed"
    end
  end

  def share
    unless NextcloudService.configured?
      redirect_to project_files_path(@project), alert: "File service not configured"
      return
    end

    begin
      @nextcloud = NextcloudService.new
      
      permissions = params[:read_only] == 'true' ? 1 : 15
      result = @nextcloud.create_share_link(@project, permissions: permissions)
      
      if result[:success]
        @share_url = result[:share_url]
        render json: { success: true, share_url: @share_url }
      else
        render json: { success: false, error: result[:error] }
      end
    rescue => e
      Rails.logger.error "Share creation error: #{e.message}"
      render json: { success: false, error: "Share creation failed" }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def authorize_project_access!
    authorize @project, :show?
  end
end
