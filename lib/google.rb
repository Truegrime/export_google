module Google      
         
      class Project
            
            def initialize(access_token_obj, project_title)
              create_worksheet(get_spreadsheets_key(access_token_obj),  project_title, access_token_obj)
            end
            #dabuj pirma (vecaka laikam) spreadsheeta post_to linku
            def get_spreadsheets_key(access_token_obj)
                get_spreadsheets_uri = 'https://spreadsheets.google.com/feeds/spreadsheets/private/full'
        
                response = access_token_obj.get(get_spreadsheets_uri)
                
                if response.status == 200
                  puts  " dabuja xml ar spredshiita linkiem"
                else
                  puts " nevar nokert spredshita linku, moz tev nav neviena?"
                end
                
                doc = Nokogiri::XML(response.body)
                post_url = doc.css("entry link").first["href"]
                
                return post_url
               #regex = /(\w{20,})/i
               #key = edit_link.match regex
            end
            #noluupo vienu hard-kodētu rindu ar pieņemtā arraya saturu
            #saņem worksheeta linku un arrayu ar datiem
            def cell_feed_loop(link, array, access_token_obj)
                xml =  '<entry xmlns="http://www.w3.org/2005/Atom"
                          xmlns:gs="http://schemas.google.com/spreadsheets/2006">
                      <id>https://spreadsheets.google.com/feeds/cells/key/worksheetId/private/full/R2C4</id>
                      <link rel="edit" type="application/atom+xml"
                          href="https://spreadsheets.google.com/feeds/cells/key/worksheetId/private/full/R2C4"/>
                      <gs:cell row="1" col="4" inputValue="=SUM(A1:B6)"/>
                      </entry>'
                 def_link = link
                for num in (1..array.length)
                        
                      add = "/R1C#{num}"
                      create_entry = Nokogiri::XML(xml)
                      get_link = def_link + add
                      
                      response = access_token_obj.get(get_link)
                      doc = Nokogiri::Slop(response.body)
                      edit_link = doc.link(:css => "[rel='edit']")["href"] 
                      
                      create_entry.at_css("id").content = edit_link 
                      link = create_entry.at_css('link')["href"] = edit_link
                      create_entry.xpath('//gs:cell').first["col"] = "#{num}"
                      create_entry.xpath('//gs:cell').first["inputValue"] = array[num - 1]
                      
                      headers = {:headers => {'Content-Type' => 'application/atom+xml', }, :body => create_entry.to_s}
                      response = access_token_obj.put(edit_link, headers)
                      
                      if response.status == 200 
                          puts "izveidoja galveni suna: #{add}" 
                      end 
                      
                      #sleep 1
                end
            end
            def create_worksheet(post_to_url,  worksheet_title, access_token_obj)
              xml = '<entry xmlns="http://www.w3.org/2005/Atom"
              xmlns:gs="http://schemas.google.com/spreadsheets/2006">
              <title>JAUNAAAaaaaaA</title>
              <gs:rowCount>80</gs:rowCount>
              <gs:colCount>15</gs:colCount>
              </entry>'
              
              doc  = Nokogiri::XML(xml)
              title = doc.at_css "title"
              title.content = worksheet_title
              create_xml = doc.to_s
              title.content = worksheet_title.to_s + "_stats"
              create_stats_xml = doc.to_s
              headers = {:headers => {'Content-Type' => 'application/atom+xml', }, :body => create_xml}
              stats_headers = {:headers => {'Content-Type' => 'application/atom+xml', }, :body => create_stats_xml}
              
              response = access_token_obj.post(post_to_url, headers)
              response2 = access_token_obj.post(post_to_url, stats_headers)
             
              if response.status == 201
                puts " pipejot izveidoja worksheetu #{worksheet_title}"
              else 
                puts "kkas nesagaja"
              end 
              
              if response2.status == 201
                puts " pipejot izveidoja worksheetu #{worksheet_title}_stats"
              else 
                puts "kkas ibio nesagaja"
              end 
              doc = Nokogiri::Slop(response.body)
              doc2 = Nokogiri::Slop(response2.body)
              link = doc.link(:css => "[rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']")["href"] 
              link2 = doc2.link(:css => "[rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']")["href"] 
              cols = %w{id project_id story_type url estimate current_state description name requested_by created_at updated_at accepted_at labels tasks}
              stats_cols = ["date", "feature count", "feature points sum", "accepted feature count", "accepted feature points sum", "bug count", "accepted bug count", "chore count"]
              
              cell_feed_loop(link, cols, access_token_obj)
              cell_feed_loop(link2, stats_cols, access_token_obj)
              
          end

      end
      
      def exist(access_token_obj, id)
           response = access_token_obj.get(get_spreadsheets_key(access_token_obj))
           doc = Nokogiri::XML(response.body)
           array = Array.new
           status = 0
           doc.css('entry title').each {|it| array << it.content}
           array.each do |a| 
             if a == id then
               status = 1
               break
             end
           end
           if status == 1
             return true
           else
             return false
           end 
      end
      
      def get_spreadsheets_key(access_token_obj)
                get_spreadsheets_uri = 'https://spreadsheets.google.com/feeds/spreadsheets/private/full'
        
                response = access_token_obj.get(get_spreadsheets_uri)
                doc = Nokogiri::XML(response.body)
                post_url = doc.css("entry link").first["href"]
                
                return post_url
      end
      
      def doit_write(access_token_obj, project_id, array_of_data, array_of_stats_data)  
          @access_token_obj = access_token_obj
          
          def find_worksheet(project_id)
               
              response = @access_token_obj.get(get_spreadsheets_key(@access_token_obj))
              doc = Nokogiri::XML(response.body)    
              parent = ""
              doc.css("entry title").each do |title|
                if title.content == project_id
                  parent = title.parent.to_s
                end
              end
              #atgriez entry objektu, kurs atbilst projekta ID
              sec = Nokogiri::Slop(parent)
              cells_link = sec.link(:css => "[rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']")["href"] 
              
              return cells_link
              #argriez kko lidzigu : feeds/cells/tkjkO7uNycHf8y0SNID8mqw/od6/private/full
          end
          def find_worksheet_stats(project_id)
              
              project_id += "_stats"
              response = @access_token_obj.get(get_spreadsheets_key(@access_token_obj))
               doc = Nokogiri::XML(response.body)    
              parent = ""
              doc.css("entry title").each do |title|
                if title.content == project_id
                  parent = title.parent.to_s
                end
              end
              #atgriez entry objektu, kurs atbilst projekta ID
              sec = Nokogiri::Slop(parent)
              cells_link = sec.link(:css => "[rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']")["href"] 
              
              return cells_link
              #vajag  linkusparbaudit
          end
          def find_blank_row(worksheet_link)
                
                row = 1
                while true do
                    link = worksheet_link + "/R#{row}C1"
                    xml = @access_token_obj.get(link)
                    doc = Nokogiri::XML(xml.body)
                    cell = doc.xpath('//gs:cell').first["inputValue"]
                    if cell.to_s.empty?
                        break
                    else
                        row += 1
                    end
                end
                
                return row
          end
          def write_stats_data_doit(empty_row, def_link, array_of_data)
              xml =  '<entry xmlns="http://www.w3.org/2005/Atom"
                          xmlns:gs="http://schemas.google.com/spreadsheets/2006">
                      <id>https://spreadsheets.google.com/feeds/cells/key/worksheetId/private/full/R2C4</id>
                      <link rel="edit" type="application/atom+xml"
                          href="https://spreadsheets.google.com/feeds/cells/key/worksheetId/private/full/R2C4"/>
                      <gs:cell row="1" col="4" inputValue="=SUM(A1:B6)"/>
                      </entry>'
              
              col = 1
              array_of_data.each do |item|
                    
                      
                    add = "/R#{empty_row}C#{col}"
                    
                    get_link = def_link + add
                    
                    response = @access_token_obj.get(get_link)
                    create_entry = Nokogiri::XML(xml)
                    doc = Nokogiri::Slop(response.body)
                    edit_link = doc.link(:css => "[rel='edit']")["href"] 
                    
                    create_entry.at_css("id").content = edit_link 
                    create_entry.at_css('link')["href"] = edit_link
                    create_entry.xpath('//gs:cell').first["col"] = "#{col}"
                    create_entry.xpath('//gs:cell').first["row"] = "#{empty_row}"
                    create_entry.xpath('//gs:cell').first["inputValue"] = item.to_s
                    
                    headers = {:headers => {'Content-Type' => 'application/atom+xml', }, :body => create_entry.to_s}
                    response = @access_token_obj.put(edit_link, headers)
                    if response.status == 201 || 200
                      puts "izveidoja ierakstu stats R#{empty_row}C#{col}"
                    end
                    col += 1
                   
              end
          end
          def write_data_doit(def_link, array_of_data)
              xml =  '<entry xmlns="http://www.w3.org/2005/Atom"
                          xmlns:gs="http://schemas.google.com/spreadsheets/2006">
                      <id>https://spreadsheets.google.com/feeds/cells/key/worksheetId/private/full/R2C4</id>
                      <link rel="edit" type="application/atom+xml"
                          href="https://spreadsheets.google.com/feeds/cells/key/worksheetId/private/full/R2C4"/>
                      <gs:cell row="1" col="4" inputValue="=SUM(A1:B6)"/>
                      </entry>'
                      
              row = 2
              array_of_data.each do |story|
                col = 1
                story.each do |s|
                        
                      add = "/R#{row}C#{col}"
                      
                      get_link = def_link + add
                      
                      response = @access_token_obj.get(get_link)
                      create_entry = Nokogiri::XML(xml)
                      doc = Nokogiri::Slop(response.body)
                      edit_link = doc.link(:css => "[rel='edit']")["href"] 
                      
                      create_entry.at_css("id").content = edit_link 
                      create_entry.at_css('link')["href"] = edit_link
                      create_entry.xpath('//gs:cell').first["col"] = "#{col}"
                      create_entry.xpath('//gs:cell').first["row"] = "#{row}"
                      create_entry.xpath('//gs:cell').first["inputValue"] = s
                      
                      headers = {:headers => {'Content-Type' => 'application/atom+xml', }, :body => create_entry.to_s}
                      response = @access_token_obj.put(edit_link, headers)
                      if response.status == 200 || 201
                        puts "ierakstija suna R#{row}C#{col}"
                      end
                      col += 1   
                end
                  row +=1   
                  
                
              end
          end


          
          write_data_doit(find_worksheet(project_id), array_of_data )
          write_stats_data_doit(find_blank_row(find_worksheet_stats(project_id)), find_worksheet_stats(project_id), array_of_stats_data)
      end


        
end

