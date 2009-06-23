class AllIssuesController < ApplicationController
  unloadable
  layout 'base'
  before_filter :find_project

  # Create a query in the session and redirects to the issue list with that query
  def index
    @query = Query.new(:name => "_")
    @query.project = @project
    @query.add_filter("status_id", '*', ['']) # All statuses      

    session[:query] = {:project_id => @query.project_id, :filters => @query.filters}

    redirect_to :controller => 'issues', :action => 'index', :project_id => @project
  end

  private
  def find_project
    @project = Project.find(params[:id])
  end
end
