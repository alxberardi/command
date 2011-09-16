require 'rtree'

module Command
  class Command

    include RTree::TreeNode

    def initialize
      @executed = false
    end


    def executed?
      @executed && children.all?(&:executed?)
    end
    
    
    def not_executed?
      !@executed && !children.any?(&:executed?)
    end
    
    
    def execute
      execute_all
    end


    def unexecute
      unexecute_all
    end
    
    
    def executed
      executed = @executed ? [self] : []
      executed + children.map(&:executed).flatten
    end
    
    
    def not_executed
      not_executed = @executed ? [] : [self]
      not_executed + children.map(&:not_executed).flatten
    end
    
    
    protected

    # To be overridden in order to contain specific execution logic
    def execute_command
      # Must return true or false depending on success
    end


    # To be overridden in order to contain specific unexecution logic
    def unexecute_command
      # Must return true or false depending on success
    end


    private

    def execute_all
      children.each(&:execute)
      return false unless children.all?(&:executed?) && !@executed && execute_command
      @executed = true
    end


    def unexecute_all
      @executed = false if @executed && unexecute_command
      !@executed && children.map(&:unexecute).all?
    end

  end
end

