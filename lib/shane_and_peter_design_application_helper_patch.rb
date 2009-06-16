module ShaneAndPeterDesignApplicationHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    # Expands the current menu item using jQuery.
    def expand_current_menu
      current_menu_class = params[:controller]
      javascript_tag("jQuery(document).ready(function($) { $.menu_expand({ menuItem: '.#{current_menu_class}.selected' }) });")
    end
  end
end
