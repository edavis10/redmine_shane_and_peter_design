module ShaneAndPeterDesignApplicationHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
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
        else
          params[:controller]
        end

                             
      javascript_tag("jQuery(document).ready(function($) { $.menu_expand({ menuItem: '.#{current_menu_class}' }) });")
    end
  end
end
