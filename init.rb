require 'redmine'

require 'shane_and_peter_design_themes_patch'
require 'shane_and_peter_design_themes_wiki_formatting_patch'

# Patches to the Redmine core.
require 'dispatcher'
require 'shane_and_peter_design_application_helper_patch'
Dispatcher.to_prepare do
  ApplicationHelper.send(:include, ShaneAndPeterDesignApplicationHelperPatch)
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

Redmine::MenuManager.map :project_menu do |menu|
  # Move "New Issue" to be under the Issues group
  menu.delete(:new_issue)
  menu.push(:new_issue,
            { :controller => 'issues', :action => 'new' },
            {
              :param => :project_id,
              :caption => :label_issue_new,
              :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue), :onclick => "return toggleNewIssue();" },
              :parent_menu => :issues
            })
  menu.push(:all_issues,
            { :controller => 'issues', :action => 'index', :set_filter => 1 },
            {
              :param => :project_id,
              :caption => :label_issue_view_all_open,
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
  
  # TODO: Need all issues
  # TODO: Need double line bar
  # TODO: Need queries

  
  # TODO: Where should this link to?
  menu.push(:reports,
            { :controller => 'projects', :action => 'show' },
            {
              :caption => :label_report_plural,
              :after => :issues
            })
  menu.push(:time_details,
            { :controller => 'timelog', :action => 'details' },
            {
              :param => :project_id,
              :caption => :label_details,
              :parent_menu => :reports,
              :if => Proc.new {|p| User.current.allowed_to?(:view_time_entries, p) }
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

  # TODO: Need to move Roadmap after Reports
  # TODO: Need Roadmap Items

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
              :param => :project_id,
              :caption => :label_new_deliverable,
              :parent_menu => :budget,
              :if => Proc.new {|p| User.current.allowed_to?(:manage_budget, p) }
            })

  # TODO: Need Settings tabs
end
