module ShaneAndPeterDesign
  module MenuHelperPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :current_menu_item, :reports
      end
    end

    module InstanceMethods
      # Override specific pages to use the Reports menu
      def current_menu_item_with_reports
        if (params[:controller] == "timelog") ||
            (params[:controller] == 'projects' && params[:action] == 'changelog') ||
            (params[:controller] == 'issues' && ['calendar','gantt'].include?(params[:action])) ||
            (params[:controller] == 'reports' && params[:action] == 'issue_report')
          @current_menu_item = :reports
        else
          current_menu_item_without_reports
        end
      end
    end
  end
end
