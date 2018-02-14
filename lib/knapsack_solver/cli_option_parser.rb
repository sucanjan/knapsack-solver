require 'optparse'
require 'knapsack_solver/cli_option_checker'

module KnapsackSolver
  # This class parses command line arguments provided to the knapsack_solver
  # binary.
  class CliOptionParser
    # Message that describes how to use this CLI utility.
    USAGE_MESSAGE = 'Usage: knapsack_solver OPTIONS DATASET_FILE...'.freeze

    # Parses command-line arguments and removes them from the array of
    # arguments.
    #
    # @param [Array] arguments the command-line arguments.
    # @return [Hash] hash of recognized options.
    #
    # rubocop:disable Metrics/AbcSize, Metric/MethodLength, Metric/BlockLength
    def self.parse(arguments)
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = USAGE_MESSAGE
        opts.on('-b', '--branch-and-bound', 'Use branch and boung method of solving') do
          options[:branch_and_bound] = true
        end
        opts.on('-d', '--dynamic-programming', 'Use dynamic programming for solving') do
          options[:dynamic_programming] = true
        end
        opts.on('-f', '--fptas', 'Use FPTAS for solving') do
          options[:fptas] = true
        end
        opts.on('-r', '--heuristic', 'Use brute force method of solving') do
          options[:heuristic] = true
        end
        opts.on('-e', '--fptas-epsilon EPS', 'Relative error for FPTAS from range (0,1)') do |eps|
          options[:fptas_epsilon] = eps
        end
        opts.on('-o', '--output DIR', 'Directory for output log files') do |dir|
          options[:output_dir] = dir
        end
        opts.on('-g', '--graphs DIR', 'Directory for graphs') do |dir|
          options[:graphs_dir] = dir
        end
        opts.on('-v', '--version', 'Show program version') do
          options[:version] = true
        end
        opts.on_tail('-h', '--help', 'Show this help message') do
          options[:help] = true
        end
      end
      parser.parse!(arguments)
      process_help_and_version_opts(options, arguments, parser.to_s)
    end
    # rubocop:enable Metrics/AbcSize, Metric/MethodLength, Metric/BlockLength

    def self.process_help_and_version_opts(options, arguments, usage_msg)
      if !options[:help] && !options[:version]
        CliOptionChecker.check(options, arguments)
        return options
      end
      if options[:help]
        puts usage_msg
      elsif options[:version]
        puts "knapsack_solver #{KnapsackSolver::VERSION}"
      end
      nil
    end
  end
end
