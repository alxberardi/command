require 'command'

module Command
  class ProcCommand < Command
    
    def initialize(execute_proc, unexecute_proc = nil)
      super()
      raise ArgumentError, "No valid execution Proc was provided" unless execute_proc.is_a?(Proc)
      @execute_proc = execute_proc
      @unexecute_proc = unexecute_proc
    end
    
    
    protected
    
    def execute_command
      @execute_proc.call
    end
    
    
    def unexecute_command
      @unexecute_proc && @unexecute_proc.call
    end
    
  end
end
