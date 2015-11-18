# replaces methods in projects_controller.rb
module ProjectPublicity
  module ProjectsNonPublicPatch
    def self.included(base)
      base.class_eval do
        def create
          @issue_custom_fields = IssueCustomField.sorted.to_a
          @trackers = Tracker.sorted.to_a
          @project = Project.new
          @project.safe_attributes = params[:project]

          unless User.current.admin?
            @project.is_public = 0
          end

          if @project.save
            unless User.current.admin?
              @project.add_default_member(User.current)
            end
            respond_to do |format|
              format.html {
                flash[:notice] = l(:notice_successful_create)
                if params[:continue]
                  attrs = {:parent_id => @project.parent_id}.reject {|k,v| v.nil?}
                  redirect_to new_project_path(attrs)
                else
                  redirect_to settings_project_path(@project)
                end
              }
              format.api  { render :action => 'show', :status => :created, :location => url_for(:controller => 'projects', :action => 'show', :id => @project.id) }
            end
          else
            respond_to do |format|
              format.html { render :action => 'new' }
              format.api  { render_validation_errors(@project) }
            end
          end
        end

        def update
          @project.safe_attributes = params[:project]

          unless User.current.admin?
            @project.is_public = 0
          end

          if @project.save
            respond_to do |format|
              format.html {
                flash[:notice] = l(:notice_successful_update)
                redirect_to settings_project_path(@project)
              }
              format.api  { render_api_ok }
            end
          else
            respond_to do |format|
              format.html {
                settings
                render :action => 'settings'
              }
              format.api  { render_validation_errors(@project) }
            end
          end
        end
      end
    end
  end
end
