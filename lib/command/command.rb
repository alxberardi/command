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


    def execute
      execute_all
    end


    def unexecute
      unexecute_all
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
      children.map(&:execute).all? && !@executed && execute_command && (@executed = true)
    end


    def unexecute_all
      children.map(&:unexecute).all? && @executed && unexecute_command && !(@executed = false)
    end

  end
end

