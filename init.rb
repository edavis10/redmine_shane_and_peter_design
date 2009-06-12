require 'redmine'

require 'shane_and_peter_design_themes_patch'
require 'shane_and_peter_design_themes_wiki_formatting_patch'

Redmine::Plugin.register :redmine_shane_and_peter_design do
  name 'Redmine Shane And Peter Design plugin'
  author 'Eric Davis'
  url 'https://redmine.shaneandpeter.com'
  author_url 'http://www.littlestreamsoftware.com'
  description "This is a plugin to implement the custom design for Shane and Peter Inc."
  version '0.1.0'

  requires_redmine :version_or_higher => '0.8.0'
end

# Move "New Issue" to be under the Issues group
Redmine::MenuManager.map :project_menu do |menu|
  menu.delete(:new_issue)
  menu.push(:new_issue,
            { :controller => 'issues', :action => 'new' },
            {
              :param => :project_id,
              :caption => :label_issue_new,
              :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue), :onclick => "return toggleNewIssue();" },
              :parent_menu => :issues
            })
end
