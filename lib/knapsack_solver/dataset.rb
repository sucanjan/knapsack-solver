require 'knapsack_solver/instance'

module KnapsackSolver
  # This class represents a set of 0/1 knapsack problem instances.
  class Dataset
    # Initializes set of 0/1 knapsack problem instances.
    #
    # @param id [Integer] Dataset ID number.
    # @param instances [Array<Instance>] set of the 0/1 knapsack problem instances.
    def initialize(id, instances)
      @id = id
      @instances = instances
    end

    # Parses set of a 0/1 knapsack problem instances from a character stream.
    #
    # @param stream [#eof?,#readline,#each_line] character stream holding the dataset.
    # @return [Dataset] dataset instance parsed from the stream.
    def self.parse(stream)
      id = parse_id(stream)
      instances = stream.each_line.with_object([]) { |l, o| o << Instance.parse(l) }
      raise StandardError, 'dataset: missing instances' if instances.empty?
      Dataset.new(id, instances)
    end

    # Parses ID of a 0/1 knapsack problem dataset from a character stream.
    #
    # @param stream [#eof?,#readline,#each_line] character stream holding the dataset.
    # @return [Integer] dataset ID number.
    def self.parse_id(stream)
      raise StandardError, 'dataset: missing ID' if stream.eof?
      s = stream.readline.split
      raise StandardError, 'dataset: first line does not contain ID' if s.size != 1
      begin
        raise StandardError, 'dataset: ID is negative' if Integer(s.first) < 0
      rescue ArgumentError
        raise StandardError, 'dataset: ID is not an integer'
      end
      Integer(s.first)
    end

    attr_reader :id, :instances
  end
end
