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
    # Must return true or false depending on success
    def execute_command
      true
    end


    # To be overridden in order to contain specific unexecution logic
    # Must return true or false depending on success
    def unexecute_command
      true
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

