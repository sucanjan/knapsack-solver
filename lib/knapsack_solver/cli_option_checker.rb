require 'optparse'

module KnapsackSolver
  # This class checks command line arguments provided to the knapsack_solver
  # binary.
  class CliOptionChecker
    # Checks command-line options, their arguments and positional arguments
    # provided to the CLI.
    #
    # @param opts [Hash] parsed command-line options
    # @param args [Array<String>] command-line positional arguments
    def self.check(opts, args)
      if !opts[:branch_and_bound] && !opts[:dynamic_programming] &&
         !opts[:fptas] && !opts[:heuristic]
        raise StandardError, 'At least one method of solving must be requested'
      end
      check_fptas_options(opts)
      check_directories(opts)
      check_positional_arguments(args)
    end

    # Checks command-line options and arguments used by FPTAS solving method.
    #
    # @param opts [Hash] parsed command-line options
    def self.check_fptas_options(opts)
      return if !opts[:fptas] && !opts.key?(:fptas_epsilon)
      check_incomplete_fptas_options(opts)
      eps = opts[:fptas_epsilon].to_f
      return unless eps <= 0 || eps >= 1 || eps.to_s != opts[:fptas_epsilon]
      raise StandardError,
            'FPTAS epsilon must be number from range (0,1)'
    end

    # Checks command-line options and arguments used by FPTAS solving
    # method. Recignizes cases when mandatory FPTAS epsilon constant is
    # missing or when it the constant is provided and FPTAS method is not
    # requested.
    #
    # @param opts [Hash] parsed command-line options
    def self.check_incomplete_fptas_options(opts)
      raise StandardError, 'Missing FPTAS epsilon constant' if opts[:fptas] && !opts.key?(:fptas_epsilon)
      return unless !opts[:fptas] && opts.key?(:fptas_epsilon)
      raise StandardError,
            'epsilon constant must not be provided when FPTAS is not selected'
    end

    # Checks directory for result and statistic output logs, and directory for
    # graph files.
    #
    # @param opts [Hash] parsed command-line options
    def self.check_directories(opts)
      check_output_directory(opts[:output_dir]) if opts[:output_dir]
      check_output_directory(opts[:graphs_dir]) if opts[:graphs_dir]
    end

    # Checks if at least one dataset input file was provided and if the input
    # files are readable.
    #
    # @param args [Array<String>] positional arguments provided to the CLI
    def self.check_positional_arguments(args)
      raise StandardError, 'Missing datset file(s)' if args.empty?
      args.each { |f| check_input_file(f) }
    end

    # Checks if an output directory exist and is writable.
    #
    # @param path [Path] path to output directory
    def self.check_output_directory(path)
      raise StandardError, "Directory '#{path}' does not exists" unless File.exist?(path)
      raise StandardError, "'#{path}' is not a directory" unless File.directory?(path)
      raise StandardError, "Directory '#{path}' is not writable" unless File.writable?(path)
    end

    # Checks if an input file exist and is readable.
    #
    # @param path [Path] path to input regular file
    def self.check_input_file(path)
      raise StandardError, "File '#{path}' does not exists" unless File.exist?(path)
      raise StandardError, "'#{path}' is not a regular file" unless File.file?(path)
      raise StandardError, "File '#{path}' is not readable" unless File.readable?(path)
    end
  end
end
