module RedmineShaneAndPeterDesign
  module Patches
    module JournalFormatterPatch
      def self.included(base)

        base.class_eval do
          unloadable

          # Show attachment changes as either:
          # - mimetype icon (e.g. PDF icon), or
          # - image thumbnail
          #
          def render_detail_with_thumbnails(detail, no_html=false)
            # no html shouldn't have thumbnail
            return render_detail_without_thumbnails(detail, no_html) if no_html
            # Non-attachments shouldn't have thumbnails
            return render_detail_without_thumbnails(detail, no_html) unless property(detail) == :attachment

            key = detail.first

            attachment = Attachment.find_by_id(key.to_s.sub("attachments", '').to_i)

            if attachment.present?
              if attachment.thumbnail?
                return content_tag(:div,
                                   link_to_attachment_as_thumbnail(attachment),
                                   :class => 'file-thumbs',
                                   :style => "height: #{attachment.thumbnail_div_height}px;")
              else
                return content_tag(:div,
                                   link_to_attachment_with_mimetype_icon(attachment),
                                   :class => 'file-thumbs')
              end
            else
              return render_detail_without_thumbnails(detail, no_html)
            end
          end
          alias_method_chain :render_detail, :thumbnails
        end
      end
    end
  end
end
