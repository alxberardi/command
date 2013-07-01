require 'command/command'
require 'command/proc_command'

describe Command::Command do
  subject(:command) { Command::Command.new }

  context 'when it can execute successfully' do
    before { command.stub(:execute_command).and_return(true) }

    it { should_not be_executed }
    it { command.execute.should be_true }

    context 'if already executed' do
      before { command.execute }

      it { should be_executed }

      it 'should not execute again' do
        command.execute.should be_false
        command.should have_received(:execute_command).once
      end
    end

    context 'with child commands' do
      let(:child_command_1) { Command::Command.new }
      let(:child_command_2) { Command::Command.new }

      before { command.add_children(child_command_1, child_command_2) }

      context 'when all child commands can execute successfully' do
        before do
          child_command_1.stub(:execute_command).and_return(true)
          child_command_2.stub(:execute_command).and_return(true)
        end

        it { command.execute.should be_true }

        context 'when executed' do
          before { command.execute }

          it { child_command_1.should have_received(:execute_command) }
          it { child_command_2.should have_received(:execute_command) }

          it { should be_executed }
          it { should_not be_not_executed }

          its(:executed) { should == [command, child_command_1, child_command_2] }
          its(:not_executed) { should be_empty }
        end
      end

      context 'when not all but at least one child command can execute successfully' do
        before do
          child_command_1.stub(:execute_command).and_return(false)
          child_command_2.stub(:execute_command).and_return(true)
        end

        it { command.execute.should be_false }

        context 'when executed' do
          before { command.execute }

          it { child_command_1.should have_received(:execute_command) }
          it { child_command_2.should have_received(:execute_command) }

          it { should_not be_executed }
          it { should_not be_not_executed }

          its(:executed) { should == [child_command_2] }
          its(:not_executed) { should == [command, child_command_1] }
        end
      end

      context 'when none of the child commands can execute successfully' do
        before do
          child_command_1.stub(:execute_command).and_return(false)
          child_command_2.stub(:execute_command).and_return(false)
        end

        it { command.execute.should be_false }

        context 'when executed' do
          before { command.execute }

          it { child_command_1.should have_received(:execute_command) }
          it { child_command_2.should have_received(:execute_command) }

          it { should_not be_executed }
          it { should be_not_executed }

          its(:executed) { should be_empty }
          its(:not_executed) { should == [command, child_command_1, child_command_2] }
        end
      end
    end


    context 'when unexecuting' do
      context 'when it can unexecute successfully' do
        before { command.stub(:unexecute_command).and_return(true) }

        context 'when not executed' do
          it 'should unexecute without actually performing the unexecution' do
            command.unexecute.should be_true
            command.should_not have_received(:unexecute_command)
          end
        end

        context 'when already executed' do
          before { command.execute }

          it 'should unexecute by performing the unexecution' do
            command.unexecute.should be_true
            command.should have_received(:unexecute_command)
          end

          context 'after a successful unexecution' do
            before { command.unexecute }
            it { should_not be_executed }
          end
        end

        context 'with child commands' do
          let(:child_command_1) { Command::Command.new }
          let(:child_command_2) { Command::Command.new }

          before do
            child_command_1.stub(:execute_command).and_return(true)
            child_command_2.stub(:execute_command).and_return(true)
            command.add_children(child_command_1, child_command_2)

            command.execute
          end

          context 'when all child commands can unexecute successfully' do
            before do
              child_command_1.stub(:unexecute_command).and_return(true)
              child_command_2.stub(:unexecute_command).and_return(true)
            end

            context 'when unexecuted' do
              before { command.unexecute }
              it { should_not be_executed }
              it { should be_not_executed }

              it { child_command_1.should have_received(:unexecute_command) }
              it { child_command_2.should have_received(:unexecute_command) }

              its(:executed) { should be_empty }
              its(:not_executed) { should == [command, child_command_1, child_command_2] }
            end
          end

          context 'when not all but at least one child command can unexecute successfully' do
            before do
              child_command_1.stub(:unexecute_command).and_return(false)
              child_command_2.stub(:unexecute_command).and_return(true)
            end

            context 'when unexecuted' do
              before { command.unexecute }
              it { should_not be_executed }
              it { should_not be_not_executed }

              it { child_command_1.should have_received(:unexecute_command) }
              it { child_command_2.should have_received(:unexecute_command) }

              its(:executed) { should == [child_command_1] }
              its(:not_executed) { should == [command, child_command_2] }
            end
          end

          context 'when none of the child commands can unexecute successfully' do
            before do
              child_command_1.stub(:unexecute_command).and_return(false)
              child_command_2.stub(:unexecute_command).and_return(false)
            end

            context 'when unexecuted' do
              before { command.unexecute }
              it { should_not be_executed }
              it { should_not be_not_executed }

              it { child_command_1.should have_received(:unexecute_command) }
              it { child_command_2.should have_received(:unexecute_command) }

              its(:executed) { should == [child_command_1, child_command_2] }
              its(:not_executed) { should == [command] }
            end
          end
        end

        context 'when it can not unexecute successfully' do
          before { command.stub(:unexecute_command).and_return(false) }

          context 'when already executed' do
            before { command.execute }

            context 'after an unsuccessful unexecuting' do
              before { command.unexecute }

              it { should be_executed }
            end
          end
        end
      end
    end


    context 'when it can not execute successfully' do
      before { command.stub(:execute_command).and_return(false) }

      it { should_not be_executed }
      it { command.execute.should be_false }
    end
  end
end


describe Command::ProcCommand do
  context 'when initialized' do
    it { expect { Command::ProcCommand.new(nil) }.to raise_error(ArgumentError, 'No valid execution Proc was provided') }
    it { expect { Command::ProcCommand.new(lambda {'Do nothing'}) }.to_not raise_error }
  end

  context 'when executing' do
    context 'if the proc can execute successfully' do
      subject(:command) { Command::ProcCommand.new(lambda {true}) }
      it { command.execute.should be_true }
    end

    context 'if the proc can not execute successfully' do
      subject(:command) { Command::ProcCommand.new(lambda {false}) }
      it { command.execute.should be_false }
    end
  end

  context 'when unexecuting' do
    before { command.execute }

    context 'if the proc can unexecute successfully' do
      subject(:command) { Command::ProcCommand.new(lambda {true}, lambda {true}) }
      it { command.unexecute.should be_true }
    end

    context 'if the proc can not unexecute successfully' do
      subject(:command) { Command::ProcCommand.new(lambda {true}, lambda {false}) }
      it { command.unexecute.should be_false }
    end

    context 'if the unexecution proc is missing' do
      subject(:command) { Command::ProcCommand.new(lambda {true}) }
      it { command.unexecute.should be_false }
    end
  end
end
