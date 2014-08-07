module ProjectPublicity
  module ProjectsNonPublicPatch
    def self.included(base)
      base.class_eval do
        def create
          @issue_custom_fields = IssueCustomField.sorted.all
          @trackers = Tracker.sorted.all
          @project = Project.new
          @project.safe_attributes = params[:project]
        
          unless User.current.admin?
            @project.is_public = 0
          end
      
          if validate_parent_id && @project.save
            @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
            # Add current user as a project member if current user is not admin
            unless User.current.admin?
              r = Role.givable.find_by_id(Setting.new_project_user_role_id.to_i) || Role.givable.first
              m = Member.new(:user => User.current, :roles => [r])
              @project.members << m
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
            
          def update
            @project.safe_attributes = params[:project]
            
            unless User.current.admin?
              @project.is_public = 0 
            end
            
            if validate_parent_id && @project.save
              @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
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
end
