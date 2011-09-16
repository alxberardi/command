require 'command/command'
require 'command/proc_command'

describe Command::Command, "upon instantiation" do
  it "should result not executed" do
    Command::Command.new.should_not be_executed
  end
end

describe Command::Command , "when executing" do
  before do
    @working_commands = []
    3.times do
      command = Command::Command.new
      command.stub(:execute_command).and_return(true)
      command.stub(:unexecute_command).and_return(true)
      @working_commands << command
    end
    @failing_commands = []
    3.times do
      command = Command::Command.new
      command.stub(:execute_command).and_return(false)
      command.stub(:unexecute_command).and_return(true)
      @failing_commands << command
    end
  end
  
  it "should not execute if already executed" do
    @working_commands[0].execute
    @working_commands[0].should_not_receive(:execute_command)
    @working_commands[0].execute.should be_false
  end
  
  it "should result executed if executed successfully" do
    @working_commands[0].execute.should be_true
    @working_commands[0].should be_executed
  end
  
  it "should not result executed if not executed successfully" do
    @failing_commands[0].execute.should be_false
    @failing_commands[0].should_not be_executed
  end
  
  it "should execute successfully if all child commands are executed successfully" do
    @working_commands[0].add_children(@working_commands[1], @working_commands[2])
    @working_commands[0].execute.should be_true
    @working_commands.each do |c|
      c.should be_executed
    end
  end
  
  it "should execute all child commands no matter the result of each single execution" do
    @working_commands[0].add_children(@working_commands[1], @failing_commands[0], @working_commands[2])
    @working_commands[0].children.each do |c|
      c.should_receive(:execute_command).once.with(no_args)
    end
    @working_commands[0].execute
  end
  
  it "should not execute successfully if at least one of the child commands is not executed successfully" do
    @working_commands[0].add_children(@working_commands[1], @failing_commands[0], @working_commands[2])
    @working_commands[0].should_not_receive(:execute_command)
    @working_commands[0].execute.should be_false
    @working_commands[0].should_not be_executed
  end
  
  it "should return the list of executed commands" do
    @working_commands[0].add_children(@working_commands[1], @failing_commands[0], @working_commands[2])
    @working_commands[0].execute
    @working_commands[0].executed.should eql [@working_commands[1], @working_commands[2]]
  end
  
  it "should return the list of not executed commands" do
    @working_commands[0].add_children(@working_commands[1], @failing_commands[0], @working_commands[2])
    @working_commands[0].execute
    @working_commands[0].unexecute
    @working_commands[0].not_executed.should eql [@working_commands[0], @working_commands[1], @failing_commands[0], @working_commands[2]]
  end
end

describe Command::Command , "when unexecuting" do
  before do
    @working_commands = []
    3.times do
      command = Command::Command.new
      command.stub(:execute_command).and_return(true)
      command.stub(:unexecute_command).and_return(true)
      @working_commands << command
    end
    @failing_commands = []
    3.times do
      command = Command::Command.new
      command.stub(:execute_command).and_return(true)
      command.stub(:unexecute_command).and_return(false)
      @failing_commands << command
    end
  end
  
  it "should unexecute without calling the unexecute_command method if not executed" do
    @working_commands[0].should_not_receive(:unexecute_command)
    @working_commands[0].unexecute.should be_true
  end
  
  it "should unexecute if previously executed" do
    @working_commands[0].execute
    @working_commands[0].should_receive(:unexecute_command).once.with(no_args)
    @working_commands[0].unexecute.should be_true
  end
  
  it "should result not executed if unexecuted successfully" do
    @working_commands[0].execute
    @working_commands[0].unexecute
    @working_commands[0].should_not be_executed
  end
  
  it "should result executed if not unexecuted successfully" do
    @failing_commands[0].execute
    @failing_commands[0].unexecute
    @failing_commands[0].should be_executed
  end
  
  it "should unexecute successfully if all child commands are unexecuted successfully" do
    @working_commands[0].add_children(@working_commands[1], @working_commands[2])
    @working_commands[0].execute
    @working_commands[0].unexecute
    @working_commands.each do |c|
      c.should_not be_executed
    end
  end
  
  it "should unexecute all child commands no matter the result of each single execution" do
    @working_commands[0].add_children(@working_commands[1], @failing_commands[0], @working_commands[2])
    @working_commands[0].execute
    @working_commands[0].children.each do |c|
      c.should_receive(:unexecute_command).once.with(no_args)
    end
    @working_commands[0].unexecute
  end
  
  it "should not unexecute successfully if at least one of the child commands is not unexecuted successfully" do
    @working_commands[0].add_children(@working_commands[1], @failing_commands[0], @working_commands[2])
    @working_commands[0].execute
    @working_commands[0].should_receive(:unexecute_command).once.with(no_args)
    @working_commands[0].should be_executed
    @working_commands[0].unexecute.should be_false
  end
  
  it "should return the list of executed commands" do
    @working_commands[0].add_children(@working_commands[1], @failing_commands[0], @working_commands[2])
    @working_commands[0].execute
    @working_commands[0].executed.should eql [@working_commands[0], @working_commands[1], @failing_commands[0], @working_commands[2]]
  end
  
  it "should return the list of not executed commands" do
    @working_commands[0].add_children(@working_commands[1], @failing_commands[0], @working_commands[2])
    @working_commands[0].execute
    @working_commands[0].unexecute
    @working_commands[0].not_executed.should eql [@working_commands[1], @working_commands[2]]
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
