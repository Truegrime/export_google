module Pivotal
  require 'rubygems'
  require 'net/http'
  require 'uri'

  def projects
    ret = ''
    token = 'b59b00c7be9e9b3aa20132f85a46de86'
    resource_uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/")
    response = Net::HTTP.start(resource_uri.host, resource_uri.port) do |http|
      http.get(resource_uri.path, {'X-TrackerToken' => token})
    end
    return response.body
  end
  def request(add = '')
          
          resource_uri = "http://www.pivotaltracker.com/services/v3/projects" + add
          http = Net::HTTP.start("www.pivotaltracker.com", 80) 
          http.get(resource_uri, {'X-TrackerToken' => token})
  end
      
      def get_projects
          projects = []
          response = request
          doc = Nokogiri::XML(response.body)
          doc.xpath("//project/id").each do |id| projects << id.content end
          return projects
      end 


      def get_stories(projects)
          
          stories = []
          story = []
          projects.each do |project_id|
              response =  request("/#{project_id}/stories")
              doc = Nokogiri::XML(response.body)
               
             
              doc.xpath("//stories/story").each do |item|
                   story << item
              end
              stories << story
              story = []
          end        
          return stories
      end
      def format_stories(projects=get_stories(get_projects))
        #atgriez 2dimensionalu masivu
          projects = get_stories(get_projects)
          projects.each do |proj|
              proj.each do |story|
                  doc = Nokogiri::XML(story.to_s)
                  index = 0
                  data_array = []
                  doc.xpath("//story").children.each do |line| 
                      index +=1  
                      if index % 2 == 0 
                          if index > 26
                              xml = line.to_s
                              doc = Nokogiri::XML(xml)
                              fs = []
                              doc.css("task").children.each do |ch| fs << ch.content end
                              da = fs.join("\n")
                              data_array << da     
                          else
                              data_array << line.content 
                          end  
                      end
                  end
              end
          end
      end
     def get_stats(projects = get_stories(get_projects))
       def check(xml, node, value)
          doc = Nokogiri::XML(xml.to_s)
          if doc.at_css(node).content == value
            return true
          else 
            return false
          end
        end
        def return_points(xml, node)
          doc = Nokogiri::XML(xml.to_s)
          value = doc.at_css(node).content
          return value.to_i
        end
        projects_data = []
        stats_data = []
        projects.each do |proj|   
            feature_count = 0
            accepted_features_count = 0
            feature_points_sum = 0  
            accepted_feature_points_sum = 0 
            bug_count = 0
            accepted_bug_count = 0
            chore_count = 0
            te = Nokogiri::XML(proj[0].to_s)
            project_id = te.at_css("project_id").content
            proj.each do |story|
              doc = Nokogiri::XML(story.to_s)
              doc.css("story_type").each do |story_type| 
              
                  if story_type.content == "feature"
                    feature_count += 1
                    feature_points_sum += return_points(story_type.parent, "estimate")
                      if check(story_type.parent, "current_state", "accepted")
                        accepted_features_count += 1
                        accepted_feature_points_sum += return_points(story_type.parent, "estimate")
                      end
                  end
                      
                  if story_type.content == "bug"
                      bug_count += 1
                      if check(story_type.parent, "current_state", "accepted")
                        accepted_bug_count += 1
                      end
                  end      
               end
             end
            stats_data <<  feature_count
            stats_data <<  feature_points_sum
            stats_data <<  accepted_features_count
            stats_data <<  accepted_feature_points_sum
            stats_data <<  bug_count
            stats_data <<  accepted_bug_count  
            stats_data <<  chore_count
            stats_data <<  project_id
            
            projects_data << stats_data
            stats_data = []
        end
        
        return projects_data
      end
     





  
  
end