module Pivotal
  require 'rubygems'
  require 'net/http'
  require 'uri'

      def projects_link
        ret = ''
        token = 'b59b00c7be9e9b3aa20132f85a46de86'
        resource_uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/")
        response = Net::HTTP.start(resource_uri.host, resource_uri.port) do |http|
          http.get(resource_uri.path, {'X-TrackerToken' => token})
        end
        return response
      end
      def stories_link(project_id)
        token = 'b59b00c7be9e9b3aa20132f85a46de86'
        resource_uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{project_id}/stories")
        response = Net::HTTP.start(resource_uri.host, resource_uri.port) do |http|
          http.get(resource_uri.path, {'X-TrackerToken' => token})
        end
        return response
      end
      def get_projects()
          projects = []
          response = projects_link()
          doc = Nokogiri::XML(response.body)
          doc.xpath("//project/id").each do |id| projects << id.content end
          return projects
      end 


      def get_stories()
          projects = get_projects
          stories = []
          story = []
          projects.each do |project_id|
            response = stories_link(project_id)
              doc = Nokogiri::XML(response.body)
              doc.xpath("//stories/story").each do |item|
                   story << item
              end
              stories << story
              story = []
          end        
          return stories
      end
      def format_stories()
          projects = get_stories
          data_array = []
          projects.each do |proj|
            stories = []
              proj.each do |story|
                  doc = Nokogiri::XML(story.to_s)
                  index = 0
                  story = []
                  status = 0
                  doc.xpath("//story").children.each do |line| 
                      index +=1  
                      if index % 2 == 0 
                        if line.node_name == "labels"
                          status = 1
                        end
                        story << line.content 
                        
                      end
                  end
                  unless story[2] == "feature"
                    story.insert(4, "")
                  end
                  unless story[5] == 'accepted'
                    story.insert(11, "")
                  end
                  if status == 0
                     story.insert(12, "")
                  end
                  stories << story
                  story = []
              end
              data_array << stories
              stories = []
          end
          return data_array
      end
     def get_stats(projects = get_stories)
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
            # "te" vajadzigs lai dabutu projekta ID, patreizeja versija as nav nepieciesams
            te = Nokogiri::XML(proj[0].to_s)
            project_id = te.at_css("project_id").content
            #No luupo cauri katram storijam zem konkreta projekta, samekle visas features, bugus un parejo, un kabina klat
            #parejos status izsauco parent
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
                  if story_type.content == "chore"
                      chore_count += 1
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
            #stats_data <<  project_id
            
            projects_data << stats_data
            stats_data = []
        end
        
        return projects_data
      end
     





  
  
end