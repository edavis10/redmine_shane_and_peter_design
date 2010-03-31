module ShaneAndPeterDesign
  module IssuesHelperPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :show_detail, :attachment_previews
      end
    end

    module InstanceMethods
      def show_detail_with_attachment_previews(detail, no_html=false, options={})
        # Not attachment
        return show_detail_without_attachment_previews(detail, no_html) if detail.property !='attachment'
        # No html
        return show_detail_without_attachment_previews(detail, no_html) if no_html

        if !detail.value.blank? && a = Attachment.find_by_id(detail.prop_key)
          if options.delete(:show_link_only)
            return link_to(h(a.filename), {:controller => 'attachments', :action => 'show', :id => a, :filename => a.filename, :only_path => false })
          end

          if a.thumbnail?
            value = content_tag(:div, link_to_attachment_as_thumbnail(a), :class => 'file-thumbs', :style => "height: #{a.thumbnail_div_height}px;")
          else
            value = content_tag(:div, link_to_attachment_with_mimetype_icon(a), :class => 'file-thumbs')
          end

          return value
        else
          return "#{l(:label_attachment)} #{detail.old_value} #{l(:label_deleted)}"
        end
      end
    end
  end
end
