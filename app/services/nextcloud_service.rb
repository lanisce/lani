class NextcloudService
  include HTTParty

  def initialize
    @base_url = Rails.application.credentials.nextcloud&.base_url || ENV['NEXTCLOUD_BASE_URL']
    @username = Rails.application.credentials.nextcloud&.username || ENV['NEXTCLOUD_USERNAME']
    @password = Rails.application.credentials.nextcloud&.password || ENV['NEXTCLOUD_PASSWORD']
    
    raise 'Nextcloud configuration missing' unless configured?
    
    self.class.base_uri @base_url
    self.class.basic_auth @username, @password
  end

  # Create a folder for a project
  def create_project_folder(project)
    folder_path = "/remote.php/dav/files/#{@username}/Projects/#{sanitize_folder_name(project.name)}"
    
    response = self.class.request(:mkcol, folder_path)
    
    if response.success? || response.code == 405 # 405 means folder already exists
      {
        success: true,
        folder_path: folder_path,
        web_url: "#{@base_url}/index.php/apps/files/?dir=/Projects/#{URI.encode_www_form_component(sanitize_folder_name(project.name))}"
      }
    else
      Rails.logger.error "Nextcloud folder creation failed: #{response.body}"
      { success: false, error: response.body }
    end
  rescue => e
    Rails.logger.error "Nextcloud folder creation error: #{e.message}"
    { success: false, error: e.message }
  end

  # Upload a file to a project folder
  def upload_file(project, file_path, file_content)
    sanitized_project_name = sanitize_folder_name(project.name)
    remote_path = "/remote.php/dav/files/#{@username}/Projects/#{sanitized_project_name}/#{File.basename(file_path)}"
    
    response = self.class.put(remote_path, body: file_content, headers: { 'Content-Type' => 'application/octet-stream' })
    
    if response.success?
      {
        success: true,
        file_path: remote_path,
        web_url: "#{@base_url}/index.php/apps/files/?dir=/Projects/#{URI.encode_www_form_component(sanitized_project_name)}"
      }
    else
      Rails.logger.error "Nextcloud file upload failed: #{response.body}"
      { success: false, error: response.body }
    end
  rescue => e
    Rails.logger.error "Nextcloud file upload error: #{e.message}"
    { success: false, error: e.message }
  end

  # List files in a project folder
  def list_project_files(project)
    sanitized_project_name = sanitize_folder_name(project.name)
    folder_path = "/remote.php/dav/files/#{@username}/Projects/#{sanitized_project_name}"
    
    response = self.class.request(:propfind, folder_path, 
      headers: { 'Depth' => '1', 'Content-Type' => 'application/xml' },
      body: propfind_xml
    )
    
    if response.success?
      parse_file_list(response.body, sanitized_project_name)
    else
      Rails.logger.error "Nextcloud file listing failed: #{response.body}"
      { success: false, error: response.body }
    end
  rescue => e
    Rails.logger.error "Nextcloud file listing error: #{e.message}"
    { success: false, error: e.message }
  end

  # Download a file from a project folder
  def download_file(project, filename)
    sanitized_project_name = sanitize_folder_name(project.name)
    file_path = "/remote.php/dav/files/#{@username}/Projects/#{sanitized_project_name}/#{filename}"
    
    response = self.class.get(file_path)
    
    if response.success?
      {
        success: true,
        content: response.body,
        content_type: response.headers['content-type']
      }
    else
      Rails.logger.error "Nextcloud file download failed: #{response.body}"
      { success: false, error: response.body }
    end
  rescue => e
    Rails.logger.error "Nextcloud file download error: #{e.message}"
    { success: false, error: e.message }
  end

  # Delete a file from a project folder
  def delete_file(project, filename)
    sanitized_project_name = sanitize_folder_name(project.name)
    file_path = "/remote.php/dav/files/#{@username}/Projects/#{sanitized_project_name}/#{filename}"
    
    response = self.class.delete(file_path)
    
    if response.success?
      { success: true }
    else
      Rails.logger.error "Nextcloud file deletion failed: #{response.body}"
      { success: false, error: response.body }
    end
  rescue => e
    Rails.logger.error "Nextcloud file deletion error: #{e.message}"
    { success: false, error: e.message }
  end

  # Create a share link for a project folder
  def create_share_link(project, permissions: 1) # 1 = read-only, 15 = read-write
    sanitized_project_name = sanitize_folder_name(project.name)
    folder_path = "/Projects/#{sanitized_project_name}"
    
    response = self.class.post('/ocs/v2.php/apps/files_sharing/api/v1/shares',
      headers: { 'OCS-APIRequest' => 'true', 'Content-Type' => 'application/x-www-form-urlencoded' },
      body: {
        path: folder_path,
        shareType: 3, # public link
        permissions: permissions
      }
    )
    
    if response.success?
      # Parse XML response to get share URL
      doc = Nokogiri::XML(response.body)
      share_url = doc.xpath('//url').text
      
      {
        success: true,
        share_url: share_url,
        permissions: permissions
      }
    else
      Rails.logger.error "Nextcloud share creation failed: #{response.body}"
      { success: false, error: response.body }
    end
  rescue => e
    Rails.logger.error "Nextcloud share creation error: #{e.message}"
    { success: false, error: e.message }
  end

  # Check if service is properly configured
  def self.configured?
    (Rails.application.credentials.nextcloud&.base_url.present? || ENV['NEXTCLOUD_BASE_URL'].present?) &&
    (Rails.application.credentials.nextcloud&.username.present? || ENV['NEXTCLOUD_USERNAME'].present?) &&
    (Rails.application.credentials.nextcloud&.password.present? || ENV['NEXTCLOUD_PASSWORD'].present?)
  end

  private

  def configured?
    @base_url.present? && @username.present? && @password.present?
  end

  def sanitize_folder_name(name)
    # Remove or replace characters that might cause issues in folder names
    name.gsub(/[^\w\s-]/, '').gsub(/\s+/, '_').strip
  end

  def propfind_xml
    <<~XML
      <?xml version="1.0"?>
      <d:propfind xmlns:d="DAV:">
        <d:prop>
          <d:displayname />
          <d:getcontentlength />
          <d:getcontenttype />
          <d:getlastmodified />
          <d:resourcetype />
        </d:prop>
      </d:propfind>
    XML
  end

  def parse_file_list(xml_body, project_folder)
    doc = Nokogiri::XML(xml_body)
    files = []
    
    doc.xpath('//d:response', 'd' => 'DAV:').each do |response|
      href = response.xpath('d:href', 'd' => 'DAV:').text
      next if href.end_with?("/Projects/#{project_folder}/") # Skip the folder itself
      
      props = response.xpath('d:propstat/d:prop', 'd' => 'DAV:').first
      next unless props
      
      filename = File.basename(href)
      next if filename.empty?
      
      files << {
        name: filename,
        size: props.xpath('d:getcontentlength', 'd' => 'DAV:').text.to_i,
        content_type: props.xpath('d:getcontenttype', 'd' => 'DAV:').text,
        modified: Time.parse(props.xpath('d:getlastmodified', 'd' => 'DAV:').text),
        is_directory: props.xpath('d:resourcetype/d:collection', 'd' => 'DAV:').any?
      }
    end
    
    { success: true, files: files }
  rescue => e
    Rails.logger.error "File list parsing error: #{e.message}"
    { success: false, error: e.message }
  end
end
