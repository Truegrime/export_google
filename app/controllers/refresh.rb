  require 'oauth2'
  
        def refresh_access_token_do_it(token_obj)
              refresh_access_token_obj = OAuth2::AccessToken.new(@client, "#{token_obj.token}", {refresh_token: "#{token_obj.refresh_token}"})
              new_token = refresh_access_token_obj.refresh!
              
              return new_token
        end 
        def check_token
            response = @access_token_obj.post("https://spreadsheets.google.com/feeds/spreadsheets/private/full")
            if response.status == 200
                puts "tokens stokinieka"
            else
                new_token = refresh_access_token_do_it(token_obj)
                @token = new_token.token
            end
        end
      
