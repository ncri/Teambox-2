module TasksHelper

  def task_id(element,project,task_list,task=nil)
    task ||= project.tasks.build
    js_id(element,project,task_list,task)
  end

  def task_link(project,task_list,task=nil)
    task ||= project.tasks.build
    app_link(project,task_list,task)
  end

  def task_form_for(project,task_list,task,&proc)
    app_form_for(project,task_list,task,&proc)
  end
  
  def task_submit(project,task_list,task)
    app_submit(project,task_list,task)
  end

  def task_form_loading(action,project,task_list,task)
    app_form_loading(action,project,task_list,task)
  end

  def show_task(project,task_list,task)    
    app_toggle(project,task_list,task)
  end  

  def hide_task(project,task_list,task)
    app_toggle(project,task_list,task)
  end

  def replace_task_column(project,task_lists,sub_action,task)
    page.replace_html 'column', task_list_column(project,task_lists,sub_action,task)
  end

  def insert_archive_box(project,task)
    page.insert_html :after, 'new_comment',  
      :partial => 'tasks/archive_box', :locals => {
      :project => project,
      :task_list => task.task_list,
      :task => task }
  end
  
  def unarchive_task_button(project,task_list,task)
    link_to_remote "<span>#{t('.unarchive')}</span>", 
      :url => unarchive_project_task_list_task_path(project,task_list,task), 
      :method => :put,
      :loading => loading_archive_task,
      :html => {
        :class => 'button', 
        :id => 'archive_button' }
  end
  
  def task_archive_box(project,task_list,task)
    return unless task.editable?(current_user)
    if task.archived
      render :partial => 'tasks/unarchive_box', :locals => {
        :project => project,
        :task_list => task_list,
        :task => task }      
    elsif task.closed?
      render :partial => 'tasks/archive_box', :locals => {
        :project => project,
        :task_list => task_list,
        :task => task }
    end  
  end

  def archive_task_button(project,task_list,task)
    link_to_remote content_tag(:span, t('.archive')), 
      :url => archive_project_task_list_task_path(project,task_list,task), 
      :method => :put,
      :loading => loading_archive_task,
      :html => {
        :class => 'button', 
        :id => 'archive_button' }
  end

  def loading_archive_task
    update_page do |page|
      page['archive_button'].className = 'loading_button'
    end  
  end


  def show_archive_task_message(task)
    page.replace 'show_task', :partial => 'tasks/archive_message', :locals => {
      :task => task }
  end
  
  def show_destroy_task_message(task)
    page.replace 'show_task', :partial => 'tasks/destroy_message', :locals => {
      :task => task }
  end

  
  def task_form(project,task_list,task)
    return unless task.editable?(current_user)
    render :partial => 'tasks/form', :locals => {
      :project => project,
      :task_list => task_list,
      :task => task }
  end


  def task_header(project,task_list,task)
    render :partial => 'tasks/header', :locals => {
      :project => project,
      :task_list => task_list,
      :task => task } 
  end

  def render_due_on(task,user)
    render :partial => 'tasks/due_on', 
    :locals => {
      :task => task,
      :user => user }
  end  

  def render_assignment(task,user)
    render :partial => 'tasks/assigned', 
    :locals => {
      :task => task,
      :user => user }
  end  


  def update_task_assignment(task,user)
    page.replace 'assigned', render_assignment(task,user)
  end
  
  def update_task_status(task,status_type)
    id = check_status_type(task,status_type)
    page.replace id, task_status(task,status_type)
  end

  def check_status_type(task,status_type)
    unless [:column,:content,:header].include?(status_type)
      raise ArgumentError, "Invalid Status type, was expecting :column, :content or :header but got #{status_type}"
    end
    case status_type
      when :column
        id = "column_task_status_#{task.id}"
      when :content
        id = "content_task_status_#{task.id}"
      when :header
        id = "header_task_status_#{task.id}"
    end    
  end

  def comment_task_status(comment)
    "<span class='task_status task_status_#{comment.status_name.underscore}'>#{localized_status_name(comment)}</span>"
  end

  def task_status(task,status_type)
    id = check_status_type(task,status_type)
    out = "<span id='#{id}' class='task_status task_status_#{task.status_name.underscore}'>"
    out << "#{localized_status_name(task)} &mdash; " unless status_type == :column
    out <<  "#{task.comments_count}</span>"
    out
  end

  def delete_task_link(project,task_list,task)
    link_to_remote t('common.delete'), 
      :url => project_task_list_task_path(project,task_list,task),
      :loading => delete_task_loading(project,task_list,task),
      :confirm => t('confirm.delete_task'), 
      :method => :delete
  end

  def delete_task_loading(project,task_list,task)
    edit_actions_id = task_id('edit_actions',project,task_list,task)
    delete_loading_id = task_id('delete_loading',project,task_list,task)
    update_page do |page|
      page[edit_actions_id].hide
      page[delete_loading_id].show
    end  
  end

  def task_action_links(project,task_list,task)
    if task.owner?(current_user)
      render :partial => 'tasks/actions',
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task }
    end
  end

  def task_list_drag_link(task_list)
    drag_image if task_list.owner?(current_user)
  end


  def task_drag_link(task)
    drag_image if task.editable?(current_user)
  end

  def list_tabular_tasks(project,task_list,tasks,sub_action)
    render :partial => 'tasks/td_task', 
      :collection => tasks,
      :as => :task,
      :locals => {
        :project => project,
        :task_list => task_list,
        :sub_action => sub_action }
  end

  def due_on(task)
    if task.overdue?
      t('tasks.overdue', :days => task.overdue) + " (#{I18n.l(task.due_on, :format => '%b %d')})"
    else
      I18n.l(task.due_on, :format => '%b %d')
    end
  end

  def list_tasks(project,task_list,tasks,current_target=nil)
    render :partial => 'tasks/task', 
      :collection => tasks,:locals => {
        :project => project,
        :task_list => task_list,
        :current_target => current_target }
  end

  def task_fields(f,project,task_list,task)
    render :partial => 'tasks/fields', :locals => { 
      :f => f,
      :project => project,
      :task_list => task_list,
      :task => task }
  end

  def render_task(project,task_list,task,comment)
    render :partial => 'tasks/show', 
      :locals => { 
        :project => project, 
        :task_list => task_list, 
        :task => task,
        :comment => comment }
  end

  def update_active_task(project,task_list,task,comment)
    page.replace_html 'content', :partial => 'tasks/show', 
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task,
        :comment => comment }

    item_id = task_id(:item,project,task_list,task)
    page.select('.task').invoke('removeClassName','active')
    page.select('.task_list').invoke('removeClassName','active')
    page.select('.task_navigation .active').invoke('removeClassName','active')
    page[item_id].addClassName('active')
  end
  
  def insert_task(project,task_list,task)  
    page.insert_html :bottom, task_list_id(:the_tasks,project,task_list),
      :partial => 'tasks/task', 
      :locals => {  
        :task => task,
        :project => project, 
        :task_list => task_list,
        :current_target => nil }
  end  
  
  def replace_task(project,task_list,task)
    page.replace task_id(:item,project,task_list,task),
      :partial => 'tasks/task', 
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task,
        :current_target => task }
  end

  def replace_task_header(project,task_list,task)
    page.replace task_id(:edit_header,project,task_list,task),
      :partial => 'tasks/header', 
      :locals => { 
        :project => project,
        :task_list => task_list,
        :task => task }
  end
  
  def localized_status_name(task)
    I18n.t('tasks.status.' + Task::STATUSES[task.status.to_i].underscore)
  end
end