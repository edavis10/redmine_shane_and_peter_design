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

      def link_to_attachment_as_thumbnail(attachment, options={})
        text = options.delete(:text) || attachment.filename
        action = options.delete(:download) ? 'download' : 'show'

        thumbnail_image = image_tag(url_for({:controller => 'attachments', :action => 'show', :id => attachment.thumbnail, :filename => attachment.thumbnail.filename }))

        link_to(thumbnail_image + h(text), {:controller => 'attachment', :action => action, :id => attachment, :filename => attachment.filename }, options)
        
      end

      def link_to_attachment_with_mimetype_icon(attachment, options={})
        text = options.delete(:text) || attachment.filename
        action = options.delete(:download) ? 'download' : 'show'

        mime_type_icon = image_tag(mime_type_icon(attachment.content_type), :plugin => 'redmine_shane_and_peter_design')

        link_to(mime_type_icon + h(text), {:controller => 'attachment', :action => action, :id => attachment, :filename => attachment.filename }, options)
      end

      def mime_type_icon(content_type)
        file = 'mimetypes/' +
          case content_type
          when /excel/
            'spreadsheet.png'
          when /msword/
            'document.png'
          when 'application/x-tar'
            'tar.png'
          when'application/gzip'
            'tar.png'
          when 'application/pdf'
            'pdf.png'
          when 'application/postscript'
            'ps.png'
          when 'application/zip'
            'tar.png'
          when 'application/x-httpd-eruby'
            'source.png'
          when 'image/bmp'
            'image2.png'
          when 'image/gif'
            'image2.png'
          when 'image/jpeg'
            'image2.png'
          when 'text/html'
            'html.png'
          when 'text/plain'
            'txt.png'
          when 'text/xml'
            'source.png'
          when 'text/x-patch'
            'source.png'
          when 'text/directory'
            'vcard.png'
          when 'video/quicktime'
            'quicktime.png'
          else
            'unknown.png'
          end

        return file
      end
    end
  end
end
