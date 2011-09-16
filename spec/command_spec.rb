require 'command/command'
require 'command/proc_command'

class TestCommand < Command::Command
  
  attr_reader :id
  attr_accessor :can_execute, :can_unexecute
  
  cattr_accessor :executions, :unexecutions
  
  @@executions = []
  @@unexecutions = []
  
  def self.reset_executions
    self.executions.clear
    self.unexecutions.clear
  end
  
  def initialize(id)
    @id = id
    @can_execute = true
    @can_unexecute = true
    super()
  end
  
  def to_s
    @id.to_s
  end
  
  
  protected 
  
  def execute_command
    self.class.executions << self.id
    @can_execute
  end
  
  def unexecute_command
    self.class.unexecutions << self.id
    @can_unexecute
  end
  
end

describe Command::Command, "upon instantiation" do
  it "should result not executed" do
    Command::Command.new.should_not be_executed
  end
end

describe Command::Command , "when executing" do
  before do
    TestCommand.reset_executions
    @commands = []
    5.times do |i|
      @commands << TestCommand.new(i)
    end
  end
  
  it "should not execute if already executed" do
    @commands[0].execute
    @commands[0].should_not_receive(:execute_command)
    @commands[0].execute.should be_false
  end
  
  it "should result executed if executed successfully" do
    @commands[0].execute.should be_true
    @commands[0].should be_executed
  end
  
  it "should not result executed if not executed successfully" do
    @commands[0].can_execute = false
    @commands[0].execute.should be_false
    @commands[0].should_not be_executed
  end
  
  it "should execute successfully if all child commands are executed successfully" do
    @commands[0].add_children(@commands[1], @commands[2])
    @commands[0].execute.should be_true
    @commands[0].each do |c|
      c.should be_executed
    end
  end
  
  it "should result executed if all children were executed successfully" do
    @commands[0].add_children(@commands[1], @commands[2])
    @commands[0].execute
    @commands[0].should be_executed
  end
  
  it "should result not executed if no child was executed successfully" do
    @commands[1].can_execute = false
    @commands[2].can_execute = false
    @commands[0].add_children(@commands[1], @commands[2])
    @commands[0].execute
    @commands[0].should be_not_executed
  end
  
  it "should not result executed if not all children were executed successfully" do
    @commands[1].can_execute = false
    @commands[0].add_children(@commands[1], @commands[2])
    @commands[0].execute
    @commands[0].should_not be_executed
  end
  
  it "should not result not executed if at least one child was executed successfully" do
    @commands[1].can_execute = false
    @commands[0].add_children(@commands[1], @commands[2])
    @commands[0].execute
    @commands[0].should_not be_not_executed
  end
  
  it "should execute all child commands no matter the result of each single execution" do
    @commands[2].can_execute = false
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].execute
    TestCommand.executions.should eql [1,2,3]
  end
  
  it "should execute only when all child commands are executed" do
    @commands[2].can_execute = false
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].execute.should be_false
    TestCommand.executions.should eql [1,2,3]
    TestCommand.reset_executions
    @commands[2].can_execute = true
    @commands[0].execute.should be_true
    TestCommand.executions.should eql [2,0]
  end
  
  it "should execute all child commands before itself" do
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].execute
    TestCommand.executions.should eql [1,2,3,0]
  end
  
  it "should not execute successfully if at least one of the child commands is not executed successfully" do
    @commands[2].can_execute = false
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].should_not_receive(:execute_command)
    @commands[0].execute.should be_false
    @commands[0].should_not be_executed
  end
  
  it "should return the list of executed commands" do
    @commands[2].can_execute = false
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].execute
    @commands[0].executed.map(&:id).should eql [1,3]
  end
  
  it "should return the list of not executed commands" do
    @commands[2].can_execute = false
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].execute
    @commands[0].unexecute
    @commands[0].not_executed.map(&:id).should eql [0,1,2,3]
  end
end

describe Command::Command , "when unexecuting" do
  before do
    TestCommand.reset_executions
    @commands = []
    5.times do |i|
      @commands << TestCommand.new(i)
    end
  end
  
  it "should unexecute without calling the unexecute_command method if not executed" do
    @commands[0].should_not_receive(:unexecute_command)
    @commands[0].unexecute.should be_true
  end
  
  it "should unexecute if previously executed" do
    @commands[0].execute
    @commands[0].should_receive(:unexecute_command).once.with(no_args).and_return(true)
    @commands[0].unexecute.should be_true
  end
  
  it "should result not executed if unexecuted successfully" do
    @commands[0].execute
    @commands[0].unexecute
    @commands[0].should_not be_executed
  end
  
  it "should result executed if not unexecuted successfully" do
    @commands[0].can_unexecute = false
    @commands[0].execute
    @commands[0].unexecute
    @commands[0].should be_executed
  end
  
  it "should unexecute successfully if all child commands are unexecuted successfully" do
    @commands[0].add_children(@commands[1], @commands[2])
    @commands[0].execute
    @commands[0].unexecute
    @commands[0].each do |c|
      c.should_not be_executed
    end
  end
  
  it "should result executed neither itself nor its children were unexecuted successfully" do
    @commands[0].can_unexecute = false
    @commands[1].can_unexecute = false
    @commands[2].can_unexecute = false
    @commands[0].add_children(@commands[1], @commands[2])
    @commands[0].execute
    @commands[0].unexecute
    @commands[0].should be_executed
  end
  
  it "should result not executed if itself and all children were unexecuted successfully" do
    @commands[0].add_children(@commands[1], @commands[2])
    @commands[0].execute
    @commands[0].unexecute
    @commands[0].should be_not_executed
  end
  
  it "should not result executed if at least one child was unexecuted successfully" do
    @commands[2].can_unexecute = false
    @commands[0].add_children(@commands[1], @commands[2])
    @commands[0].execute
    @commands[0].unexecute
    @commands[0].should_not be_executed
  end
  
  it "should not result not executed if not all children were unexecuted successfully" do
    @commands[1].can_unexecute = false
    @commands[0].add_children(@commands[1], @commands[2])
    @commands[0].execute
    @commands[0].unexecute
    @commands[0].should_not be_not_executed
  end
  
  it "should unexecute all child commands no matter the result of each single unexecution" do
    @commands[2].can_unexecute = false
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].execute
    @commands[0].should_receive(:unexecute_command).once.with(no_args).and_return(true)
    @commands[1].should_receive(:unexecute_command).once.with(no_args).and_return(true)
    @commands[2].should_receive(:unexecute_command).once.with(no_args).and_return(false)
    @commands[3].should_receive(:unexecute_command).once.with(no_args).and_return(true)
    @commands[0].unexecute
  end
  
  it "should unexecute even if not all child commands are unexecuted" do
    @commands[2].can_unexecute = false
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].execute
    @commands[0].unexecute.should be_false
    TestCommand.unexecutions.should eql [0,1,2,3]
    TestCommand.reset_executions
    @commands[2].can_unexecute = true
    @commands[0].unexecute.should be_true
    TestCommand.unexecutions.should eql [2]
  end
  
  it "should unexecute itself before all child commands" do
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].execute
    @commands[0].unexecute
    TestCommand.unexecutions.should eql [0,1,2,3]
  end
  
  it "should not unexecute successfully if at least one of the child commands is not unexecuted successfully" do
    @commands[2].can_unexecute = false
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].execute
    @commands[0].should_receive(:unexecute_command).once.with(no_args).and_return(true)
    @commands[0].should be_executed
    @commands[0].unexecute.should be_false
  end
  
  it "should return the list of executed commands" do
    @commands[2].can_unexecute = false
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].execute
    @commands[0].unexecute
    @commands[0].executed.map(&:id).should eql [2]
  end
  
  it "should return the list of not executed commands" do
    @commands[2].can_unexecute = false
    @commands[0].add_children(@commands[1], @commands[2], @commands[3])
    @commands[0].execute
    @commands[0].unexecute
    @commands[0].not_executed.map(&:id).should eql [0,1,3]
  end
end

describe Command::ProcCommand, "upon instantiation" do
  it "should only allow to be initialized if a Proc is provided" do
    lambda { Command::ProcCommand.new(nil) }.should raise_error(ArgumentError, "No valid execution Proc was provided")
    lambda { Command::ProcCommand.new(lambda {"Do nothing"}) }.should_not raise_error
  end
end

describe Command::ProcCommand, "when executing" do
  before do
    @working_command = Command::ProcCommand.new(lambda {true})
    @failing_command = Command::ProcCommand.new(lambda {false})
  end
  
  it "should result executed if the proc is executed successfully" do
    @working_command.execute.should be_true
    @working_command.should be_executed
  end
  
  it "should not result executed if the proc is not executed successfully" do
    @failing_command.execute.should be_false
    @failing_command.should_not be_executed
  end
end

describe Command::ProcCommand, "when unexecuting" do
  before do
    @working_command = Command::ProcCommand.new(lambda {true}, lambda {true})
    @failing_command = Command::ProcCommand.new(lambda {true}, lambda {false})
    @not_unexecutable_command = Command::ProcCommand.new(lambda {true})
    
    @working_command.execute
    @failing_command.execute
    @not_unexecutable_command.execute
  end
  
  it "should result not executed if the proc is unexecuted successfully" do
    @working_command.unexecute.should be_true
    @working_command.should_not be_executed
  end
  
  it "should result executed if the proc is not unexecuted successfully" do
    @failing_command.unexecute.should be_false
    @failing_command.should be_executed
  end
  
  it "should not unexecute if the unexecute proc is not present" do
    @not_unexecutable_command.unexecute.should be_false
    @not_unexecutable_command.should be_executed
  end
end
