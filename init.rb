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
  # TODO: Need all issues
  # TODO: Need questions
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

  # TODO: Need to move Roadmap after Reports
  # TODO: Need Roadmap Items
  # TODO: Need new News subitem
  # TODO: Need Wiki items
  # TODO: Need Budget subitems
  # TODO: Need Settings tabs
end
