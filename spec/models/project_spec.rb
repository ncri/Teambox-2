require File.dirname(__FILE__) + '/../spec_helper'

describe Project do

  it { should belong_to(:user)}
  it { should have_many(:people) }
  it { should have_many(:users) }

  it { should have_many(:task_lists) }
  it { should have_many(:tasks) }
  it { should have_many(:invitations) }
  it { should have_many(:conversations) }
  it { should have_many(:pages) }
  it { should have_many(:comments) }
  it { should have_many(:uploads) }
  it { should have_many(:activities) }

  it { should validate_presence_of    :user }
  # it { should validate_associated     :people }
  it { should validate_length_of      :name, :minimum => 3 }
  it { should validate_length_of      :permalink, :minimum => 5 }

  describe "creating" do 
    before do
      @owner = Factory.create(:user)
      @project = Factory.create(:project, :user_id => @owner.id)
    end
    
    it "should belong to its owner" do
      @project.user.should == @owner
      @project.owner?(@owner).should be_true
      @project.users.should include(@owner)
      @owner.reload
      @owner.projects.should include(@project)
    end
    
    it "should add users to the project, only once" do
      user = Factory.create(:user)
      person = @project.add_user(user)
      person.user.should == user
      person.project.should == @project
      @project.should have(2).users
      lambda { @project.add_user(user) }.should_not change(@project, :users)
      Activity.last.project.should == @project
      Activity.last.comment_type.should == nil
      Activity.last.target.should == person
      Activity.last.action.should == 'create'
      Activity.last.user.should == user
    end
    
    it "should log when a user is added to a project" do
      user = Factory.create(:user)
    end
    
    it "should remove users" do
      user = Factory.create(:user)
      person = @project.add_user(user)
      @project.should have(2).users
      @project.reload.remove_user(user)
      @project.should have(1).users
      @project.users.should_not include(user)
      user.reload.projects.should_not include(@project)
#      Activity.last.project.should == @project
#      Activity.last.comment_type.should == nil
#      Activity.last.target.should == person
#      Activity.last.action.should == 'delete'
#      Activity.last.user.should == user
    end
    
    it "make sure activities still work when the object is deleted"
  end
  
  describe "permalinks" do
    it "should use the given permalink if not taken" do
      project1 = Factory.create(:project, {:name => 'Alice Lidell', :permalink => 'mad-hatter'})
      project1.permalink.should == 'mad-hatter'
      project2 = Factory.create(:project, {:name => 'Lorina Lidell', :permalink => 'mad-hatter'})
      project2.permalink.should == 'mad-hatter-2'
    end
    
    it "should generate a unique permalink if none is given" do
      project1 = Factory.create(:project, :name => 'Cheshire   Cat!!')
      project1.permalink.should == 'cheshire-cat'
      project2 = Factory.create(:project, :name => 'Cheshire Cat')
      project2.permalink.should == 'cheshire-cat-2'
    end
  end
  
  describe "deleting projects" do
    before do
      @project = Factory(:project)
      @project.new_comment(@project.user, @project, :body => 'wall comment').save!
      @project.new_conversation(@project.user, :name => 'conversation', :body => 'body').save!
      @project.new_task_list(@project.user, :name => 'task list').save!
      @project.new_page(@project.user, :name => 'project page').save!
      #@project.new_upload(@project.user).save!
      @project.reload
      @project.comments.reload
    end
    
    it "should have some elements" do
      Project.count.should == 1
      Comment.count.should == 2
      Conversation.count.should == 1
      TaskList.count.should == 1
      Page.count.should == 1
      Person.count.should == 1
    end
    
    it "destroy all its comments, conversations, task lists, pages, uploads and people" do
      @project.destroy
      Project.count.should == 0
      Comment.count.should == 0
      Conversation.count.should == 0
      TaskList.count.should == 0
      Page.count.should == 0
      Person.count.should == 0
    end
    
  end

  describe "factories" do
    it "should generate Ruby Rockstars project with Mislav in it" do
      project = Factory.create(:ruby_rockstars)
      project.valid?.should be_true
      project.users.first.should == User.find_by_login('mislav')
    end
  end
end