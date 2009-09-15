require 'redmine'

require 'shane_and_peter_design/themes_patch'
require 'shane_and_peter_design/themes_wiki_formatting_patch'

# Patches to the Redmine core.
require 'dispatcher'
require 'shane_and_peter_design/application_helper_patch'
Dispatcher.to_prepare do
  ApplicationHelper.send(:include, ShaneAndPeterDesign::ApplicationHelperPatch)
  Redmine::MenuManager::MenuHelper.send(:include, ShaneAndPeterDesign::MenuHelperPatch)
end


Redmine::Plugin.register :redmine_shane_and_peter_design do
  name 'Redmine Shane And Peter Design plugin'
  author 'Eric Davis'
  url 'https://redmine.shaneandpeter.com'
  author_url 'http://www.littlestreamsoftware.com'
  description "This is a plugin to implement the custom design for Shane and Peter Inc."
  version '0.1.0'

  requires_redmine :version_or_higher => '0.8.0'
end

require 'redmine/i18n'
extend Redmine::I18n
require 'projects_helper'
extend ProjectsHelper

Redmine::MenuManager.map :project_menu do |menu|
  query_proc = Proc.new { |p|
    ##### Taken from IssuesHelper
    # User can see public queries and his own queries
    visible = ARCondition.new(["is_public = ? OR user_id = ?", true, (User.current.logged? ? User.current.id : 0)])
    # Project specific queries and global queries
    visible << (p.nil? ? ["project_id IS NULL"] : ["project_id IS NULL OR project_id = ?", p.id])
    sidebar_queries = Query.find(:all, 
                                 :select => 'id, name',
                                 :order => "name ASC",
                                 :conditions => visible.conditions)

    returning [] do |menu_items|
      sidebar_queries.each do |query|
        menu_items <<  Redmine::MenuManager::MenuItem.new(
                                    "query-#{query.id}".to_sym,
                                    { :controller => 'issues', :action => 'index', :project_id => p, :query_id => query },
                                    {
                                      :caption => query.name,
                                      :param => :project_id,
                                      :parent_menu => :issues
                              })
      end
    end
  }
    
  # Add Queries as child_submenus
  menu.delete(:issues)
  menu.push(:issues,
            { :controller => 'issues', :action => 'index' },
            {
              :param => :project_id,
              :caption => :label_issue_plural,
              :child_menus => query_proc,
              :after => :overview
            })
  
  # Move "New Issue" to be under the Issues group
  menu.delete(:new_issue)
  menu.push(:new_issue,
            { :controller => 'issues', :action => 'new' },
            {
              :param => :project_id,
              :caption => :label_issue_new,
              :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue) },
              :parent_menu => :issues
            })
  menu.push(:all_open_issues,
            { :controller => 'issues', :action => 'index', :set_filter => 1 },
            {
              :param => :project_id,
              :caption => :label_issue_view_all_open,
              :parent_menu => :issues
            })
  menu.push(:all_issues,
            { :controller => 'all_issues', :action => 'index' },
            {
              :caption => :label_issue_view_all,
              :parent_menu => :issues
            })
  begin
    require 'question' unless Object.const_defined?('Question')

    menu.push(:questions,
              { :controller => 'questions', :action => 'my_issue_filter'},
              {
                :param => :project,
                :caption => :text_questions_for_me,
                :parent_menu => :issues
              })
  rescue LoadError
    # question_plugin is not installed, skip
  end
  
  menu.push(:reports,
            { :controller => 'timelog', :action => 'details' },
            {
              :param => :project_id,
              :caption => :label_report_plural,
              :after => :issues,
              :if => Proc.new {|p| User.current.allowed_to?(:view_time_entries, p) }
            })

  # TODO: Pull for release
  if false && Redmine::Plugin.registered_plugins.keys.include?(:redmine_overhead)
    menu.push(:billable_time_details,
              { :controller => 'timelog', :action => 'details' },
              {
                :param => :project_id,
                :caption => Proc.new {|p|
                  # OPTIMIZE
                  TimeEntry.visible_by(User.current) do
                    @time_entries = TimeEntry.all(:include => [:project, {:activity => :custom_values}],
                                                  :conditions => p.project_condition(Setting.display_subprojects_issues?))
                  end
                  @total_hours = @time_entries.collect {|te| te.billable? ? te.hours : 0}.sum

                  l(:overhead_field_billable) + ' ' + l_hours(@total_hours)
                },
                :parent_menu => :reports,
                :if => Proc.new {|p| User.current.allowed_to?(:view_time_entries, p) }
              })
    menu.push(:overhead_time_details,
              { :controller => 'timelog', :action => 'details' },
              {
                :param => :project_id,
                :caption => Proc.new {|p|
                  # OPTIMIZE
                  TimeEntry.visible_by(User.current) do
                    @time_entries = TimeEntry.all(:include => [:project, {:activity => :custom_values}],
                                                  :conditions => p.project_condition(Setting.display_subprojects_issues?))
                  end
                  @total_hours = @time_entries.collect {|te| te.billable? ? 0 : te.hours}.sum

                  l(:overhead_field_overhead) + ' ' + l_hours(@total_hours)

                },
                :parent_menu => :reports,
                :if => Proc.new {|p| User.current.allowed_to?(:view_time_entries, p) }
              })
  end

  menu.push(:issue_summary,
            { :controller => 'reports', :action => 'issue_report' },
            {
              :caption => :field_issue_summary,
              :parent_menu => :reports
            })
  menu.push(:issue_changelog,
            { :controller => 'projects', :action => 'changelog' },
            {
              :caption => :label_change_log,
              :parent_menu => :reports
            })
  menu.push(:time_reports,
            { :controller => 'timelog', :action => 'report' },
            {
              :param => :project_id,
              :caption => :label_report,
              :parent_menu => :reports,
              :if => Proc.new {|p| User.current.allowed_to?(:view_time_entries, p) }
            })
  menu.push(:calendar,
            { :controller => 'issues', :action => 'calendar' },
            {
              :param => :project_id,
              :caption => :label_calendar,
              :parent_menu => :reports,
              :if => Proc.new {|p| User.current.allowed_to?(:view_calendar, p, :global => true) }
            })
  menu.push(:gantt,
            { :controller => 'issues', :action => 'gantt' },
            {
              :param => :project_id,
              :caption => :label_gantt,
              :parent_menu => :reports,
              :if => Proc.new {|p| User.current.allowed_to?(:view_gantt, p, :global => true) }
            })

  menu.delete(:roadmap)
  menu.push(:roadmap,
            { :controller => 'projects', :action => 'roadmap' },
            {
              :if => Proc.new { |p| p.versions.any? },
              :child_menus => Proc.new { |p|
                returning [] do |children|
                  p.versions.each do |version|

                    children << Redmine::MenuManager::MenuItem.new(
                                                       "version-#{version.id}".to_sym,
                              { :controller => 'versions', :action => 'show', :id => version },
                              {
                                :caption => version.name,
                                :parent_menu => :roadmap
                              })
                    
                  end
                end
              },
              :after => :reports
            })
  
  # Wiki submenu
  menu.push(:wiki_home,
            { :controller => 'wiki', :action => 'index', :page => nil },
            {
              :caption => :field_start_page,
              :parent_menu => :wiki
            })
  menu.push(:wiki_by_title,
            { :controller => 'wiki', :action => 'special', :page => 'Page_index' },
            {
              :caption => :label_index_by_title,
              :parent_menu => :wiki
            })
  menu.push(:wiki_by_date,
            { :controller => 'wiki', :action => 'index', :page => 'Date_index' },
            {
              :caption => :label_index_by_date,
              :parent_menu => :wiki
            })


  # News submenu
  menu.push(:new_news,
            { :controller => 'news', :action => 'new' },
            {
              :param => :project_id,
              :caption => :label_news_new,
              :parent_menu => :news,
              :if => Proc.new {|p| User.current.allowed_to?(:manage_news, p) }
            })
  
  # Budget submenu
  # TODO: plugin needs a new deliverable endpoint
  menu.push(:new_deliverable,
            { :controller => 'deliverables', :action => 'index' },
            {
              :caption => :label_new_deliverable,
              :parent_menu => :budget,
              :if => Proc.new {|p| User.current.allowed_to?(:manage_budget, p) }
            })

  menu.delete :settings
  menu.push(:settings,
            { :controller => 'projects', :action => 'settings' },
            {
              :last => true,
              :child_menus => Proc.new { |p|
                returning [] do |children|
                  @project = p # @project used in the helper
                  project_settings_tabs.each do |tab|

                    children << Redmine::MenuManager::MenuItem.new(
                              "settings-#{tab[:name]}".to_sym,
                              { :controller => 'projects', :action => 'settings', :id => p, :tab => tab[:name] },
                              {
                                :caption => tab[:label]
                              })
                    
                  end
                end
              }
            })

end
