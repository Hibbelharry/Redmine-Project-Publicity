require 'projects_non_public_patch'

Redmine::Plugin.register :project_publicity do
  name 'Project Publicity plugin'
  author 'Author name'
  description 'Du musst den Ordner "project_publicity" nennen'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  
  Rails.configuration.to_prepare do
    ProjectsController.send(:include, ProjectPublicity::ProjectsNonPublicPatch)
  end
end
