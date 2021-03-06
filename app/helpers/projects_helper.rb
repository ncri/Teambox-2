module ProjectsHelper

  def list_users_statuses(users)
    render :partial => 'users/status', :collection => users, :as => :user
  end
  
  def list_projects(projects)
    unless @projects.empty?
    render :partial => 'shared/projects', :locals => { :projects => projects }
    end
  end
  
  def project_link(project)
    link_to h(project.name), project_path(project)
  end
  
  def new_project_link
    link_to content_tag(:span, t('.new_project')), new_project_path, :class => 'add_button', :id => 'new_project_link'
  end

  def project_fields(f,project)
    render :partial => 'fields', 
      :locals => { 
        :f => f,
        :project => project }
  end
   
  def project_primer
    render :partial => 'projects/primer'
  end  
  
end