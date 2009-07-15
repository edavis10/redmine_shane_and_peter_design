module ShaneAndPeterDesign
  module ApplicationHelperPatch
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
          when params[:controller] == 'deliverables'
            'budget'
          else
            params[:controller]
          end

        
        javascript_tag("jQuery(document).ready(function($) { $.menu_expand({ menuItem: '.#{current_menu_class}' }) });")
      end

      def link_to_attachment_with_thumbnail_preview(attachment, options={})
        text = options.delete(:text) || attachment.filename
        action = options.delete(:download) ? 'download' : 'show'
        options = options.merge({:class => 'has-thumb'})
        
        thumbnail_image = image_tag(url_for({:controller => 'attachments', :action => 'show', :id => attachment.thumbnail, :filename => attachment.thumbnail.filename }))
        
        link_to(h(text) + thumbnail_image,
                {:controller => 'attachments', :action => action, :id => attachment, :filename => attachment.filename },
                options)
      end
    end
  end
end
