# Patch the wikitoolbar_for so it only includes the JavaScript tags once

module Redmine
  module WikiFormatting
    module Textile
      module Helper
        #
        # Override the wikitoolbar_for method adding a check around
        # the javascript_tag that inserts the toolbar.  Otherwise
        # thickbox will eval the code twice giving you double the
        # WYSIWYG buttons
        def wikitoolbar_for(field_id)
          # Is there a simple way to link to a public resource?
          url = "#{Redmine::Utils.relative_url_root}/help/wiki_syntax.html"
          
          help_link = l(:setting_text_formatting) + ': ' +
            link_to(l(:label_help), url,
                    :onclick => "window.open(\"#{ url }\", \"\", \"resizable=yes, location=no, width=300, height=640, menubar=no, status=no, scrollbars=yes\"); return false;")

            js = <<-EOJS
                 if (typeof tb == "undefined") {
                   var tb = new jsToolBar($('#{field_id}'));
                   tb.setHelpLink('#{help_link}');
                   tb.draw();
                 }
            EOJS

          return javascript_include_tag('jstoolbar/jstoolbar') +
            javascript_include_tag('jstoolbar/textile') +
            javascript_include_tag("jstoolbar/lang/jstoolbar-#{current_language}") +
            javascript_tag(js)
        end
      end
    end
  end
end
