class DoitController < ApplicationController
  include Google
 
      
  def all
      redirect_uri ='http://localhost:3000'
      client_id = '948979649674-fb8fkd54remotm1r0tgqtqt4rris88tn.apps.googleusercontent.com'
      client_secret = 'oAcH17CdOoSTovktQPrLfiFB'
      scope = 'https://docs.google.com/feeds/ https://docs.googleusercontent.com/ https://spreadsheets.google.com/feeds/ https://www.googleapis.com/auth/drive'
   
          @client = OAuth2::Client.new(client_id, client_secret, {    :site => 'https://accounts.google.com', 
                                                                      :authorize_url => "/o/oauth2/auth", 
                                                                      :token_url => "/o/oauth2/token"})
          @link = @client.auth_code.authorize_url(:scope => scope, 
                                                  :access_type => "offline", 
                                                  :redirect_uri => redirect_uri, 
                                                  :approval_prompt => 'force')  
         if params[:code] 
            code = params[:code]
            child = fork do                 
            conan(code)  
            end
            Process.detach(child)
         end             
  end  
 
  def conan(code)    
              
              
              token_obj = @client.auth_code.get_token(code, { :redirect_uri => 'http://localhost:3000', 
                                                              :token_method => :post })
              token = token_obj.token 
              access_token_obj = OAuth2::AccessToken.new(@client, token)
              
              project_id = 'ofigetj'
              array_of_data = %w{pirmsid otrsid tresais ceturtais piektais sestais septitais}
              array_of_stats_data = %w{viens cipars otrs cipars tresais ceturtais}
              
              if exist(access_token_obj, project_id)
                  doit_write(access_token_obj, project_id, array_of_data, array_of_stats_data)  
              else
                  project = Project.new(access_token_obj, project_id)
                  doit_write(access_token_obj, project_id, array_of_data, array_of_stats_data)
              end
              
  end

end
