require 'redmine'

require 'shane_and_peter_design/themes_wiki_formatting_patch'

# Patches to the Redmine core.
require 'dispatcher'
Dispatcher.to_prepare do
  begin
    require_dependency 'application'
  rescue LoadError
    require_dependency 'application_controller' # Rails 2.3
  end
  ApplicationController.send(:include, ShaneAndPeterDesign::ApplicationControllerPatch)

  if defined?(InheritedResources::Base)
    InheritedResources::Base.send(:include, ShaneAndPeterDesign::ApplicationControllerPatch)
  end
  
  unless Redmine::MenuManager::MenuHelper.included_modules.include? ShaneAndPeterDesign::MenuHelperPatch
    Redmine::MenuManager::MenuHelper.send(:include, ShaneAndPeterDesign::MenuHelperPatch)
  end
  # Add custom theme
  require_dependency 'redmine/themes'
  unless Redmine::Themes.included_modules.include? RedmineShaneAndPeterDesign::Patches::ThemesPatch
    Redmine::Themes.send(:include, RedmineShaneAndPeterDesign::Patches::ThemesPatch)
  end

  require_dependency 'journal_formatter'
  unless JournalFormatter.included_modules.include? RedmineShaneAndPeterDesign::Patches::JournalFormatterPatch
    JournalFormatter.send(:include, RedmineShaneAndPeterDesign::Patches::JournalFormatterPatch)
  end

  # Thumbnail support.
  require_dependency 'journal'
  Journal.send(:include, ActionView::Helpers::AssetTagHelper)
  Journal.send(:include, ShaneAndPeterDesignHelper)
end


Redmine::Plugin.register :redmine_shane_and_peter_design do
  name 'Redmine Shane And Peter Design plugin'
  author 'Eric Davis'
  url 'https://redmine.shaneandpeter.com'
  author_url 'http://www.littlestreamsoftware.com'
  description "This is a plugin to implement the custom design for Shane and Peter Inc."
  version '0.1.0'

  requires_redmine :version_or_higher => '0.8.0'

  settings({
             :partial => 'settings/shane_and_peter_design',
             :default => {
               'custom_css' => '',
               'custom_javascript' => ''
             }})
end

require 'redmine/i18n'
extend Redmine::I18n
require 'projects_helper'
extend ProjectsHelper

Redmine::MenuManager.map :project_menu do |menu|
  begin
    require 'question' unless Object.const_defined?('Question')

    menu.push(:questions,
              { :controller => 'questions', :action => 'my_issue_filter'},
              {
                :param => :project,
                :caption => :text_questions_for_me,
                :parent => :issues
              })
  rescue LoadError
    # question_plugin is not installed, skip
  end
  
  menu.delete(:time_entries)
  menu.push(:reports,
            { :controller => 'timelog', :action => 'index' },
            {
              :param => :project_id,
              :caption => :label_report_plural,
              :after => :issues,
              :if => Proc.new {|p| User.current.allowed_to?(:view_time_entries, p) }
            })
  menu.push(:time_reports,
            { :controller => 'time_entry_reports', :action => 'report' },
            {
              :param => :project_id,
              :caption => :label_report,
              :parent => :reports,
              :if => Proc.new {|p| User.current.allowed_to?(:view_time_entries, p) }
            })

  # Wiki submenu
  wiki_pages_watched_proc = Proc.new {|p|
    if p && p.wiki
      returning [] do |menu_items|
        p.wiki.pages.watched_by(User.current).each do |page|
          menu_items << Redmine::MenuManager::MenuItem.new(
                                                           "wiki-page-#{page.id}".to_sym,
                                                           { :controller => 'wiki', :action => 'show', :project_id => p, :id => page.title},
                                                           {
                                                             :caption => page.pretty_title,
                                                             :param => :project_id,
                                                             :parent => :wiki_home
                                                           })
        end
      end
    end
  }
  menu.delete(:wiki)
  # Adds watches wiki pages as a child menu
  menu.push(:wiki,
            { :controller => 'wiki', :action => 'show', :id => nil },
            {
              :if => Proc.new { |p| p.wiki && !p.wiki.new_record? },
              :children => wiki_pages_watched_proc,
              :param => :project_id
            })
end
