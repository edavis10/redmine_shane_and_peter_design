module RedmineShaneAndPeterDesign
  module Patches
    module ThemesPatch
      def self.included(base)
        base.class_eval do
          unloadable

          # Add the plugin's assets/themes to the theme paths
          def self.theme_paths_with_shane_and_peter_design_theme
            themes = theme_paths_without_shane_and_peter_design_theme

            bundled_themes = File.expand_path(Rails.public_path +
                                              "/plugin_assets/redmine_shane_and_peter_design/themes")
            themes << bundled_themes
            themes
          end

          class << self
            alias_method_chain :theme_paths, :shane_and_peter_design_theme
          end
        end
      end
    end
  end
end
