class DoitController < ApplicationController
  include Google
  include Pivotal
  
      
  def all
    
    def get_code
       until params[:code]
          sleep 1
       end  
       code = params[:code]
    end
    
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
         
       
          
     
          
          child = fork do 
          token_obj = @client.auth_code.get_token(get_code, { :redirect_uri => 'http://localhost:3000', 
                                                          :token_method => :post })
          token = token_obj.token 
          @access_token_obj = OAuth2::AccessToken.new(@client, token) 
          conan(format_stories, get_stats)
          
          end
          Process.detach(child)
       
  end  
 
  def  conan(projects, projects_stats)
    i = 0
    projects.each do |proj|
      proj_stats = projects_stats[i]
        puts "sak rakstit projektu"
        project_id = proj[0][1]
        puts "#########################################################################"
        if exist(@access_token_obj, project_id)
            doit_write(@access_token_obj, project_id, proj, proj_stats) 
            puts "sarakstija"
        else
            project = Project.new(@access_token_obj, project_id)
            doit_write(@access_token_obj, project_id, proj, proj_stats)
            puts "sarakstija"
        end
        i +=1
      end
    end
end
