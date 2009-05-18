# Patch the Redmine ApplicationHelper so theme styles are not used
module ApplicationHelper
  def stylesheet_path(source)
    super(source)
  end
end

