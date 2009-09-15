module ShaneAndPeterDesign
  module ApplicationHelperPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      # Custom includes for tweaking the design and behavior on the fly
      def custom_theme_includes
        if Rails.env == 'production'
          return (stylesheet_link_tag('http://files.shaneandpeter.com/redmine/style-live.css') +
                  javascript_include_tag('http://files.shaneandpeter.com/redmine/javascript-live.js'))
        else
          return (stylesheet_link_tag('http://files.shaneandpeter.com/redmine/style.css') +
                  javascript_include_tag('http://files.shaneandpeter.com/redmine/javascript.js'))
        end
      end
      
      # Expands the current menu item using jQuery.
      def expand_current_menu
        current_menu_class =
          case 
          when params[:controller] == "timelog"
            "reports"
          when params[:controller] == 'projects' && params[:action] == 'changelog'
            "reports"
          when params[:controller] == 'issues' && ['calendar','gantt'].include?(params[:action])
            "reports"
          when params[:controller] == 'projects' && params[:action] == 'roadmap'
            'roadmap'
          when params[:controller] == 'versions' && params[:action] == 'show'
            'roadmap'
          when params[:controller] == 'projects' && params[:action] == 'settings'
            'settings'
          when params[:controller] == 'deliverables'
            'budget'
          else
            params[:controller]
          end

        
        javascript_tag("jQuery.menu_expand({ menuItem: '.#{current_menu_class}' });")
      end
    end
  end
end
