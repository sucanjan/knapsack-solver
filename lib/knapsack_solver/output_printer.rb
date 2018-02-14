module KnapsackSolver
  # This class provides support for printing results and statistics of a
  # dataset solving either to stdout or to a text file.
  class OutputPrinter
    # Initializes printer for output log (results, statistics).
    #
    # @param dataset_filenames [Array<String>] dataset filenames
    # @param suffix [String] suffix of the created files
    # @param results [Hash] results of solving or statistics to print
    def initialize(dataset_filenames, suffix, results)
      @dataset_basenames = file_basenames(dataset_filenames)
      @suffix = suffix
      @results = results
    end

    # Prints results or statistics to stdout or to files in output directory.
    #
    # @param out_dir [String] path to output directory
    def print(out_dir = nil)
      @results.each_value.with_index do |results, index|
        results.each do |method, res|
          print_solving_method_results(method, res, out_dir, @dataset_basenames[index])
        end
      end
    end

    protected

    # Prints results of solving or statistics.
    #
    # @param method [Symbol] symbol for solving method
    # @param res [Hash] results of the solving method
    # @param out_dir [String] path to output directory
    # @param basename [String] basename of dataset input file corresponding to the results
    def print_solving_method_results(method, res, out_dir, basename)
      of = output_filename(out_dir, basename, method.to_s)
      os = output_stream(out_dir, of)
      print_header(os, of, res)
      res.each do |r|
        os.puts r.values.each_with_object([]) { |v, a| a << v.to_s }.join(' ')
      end
      os.puts if out_dir.nil?
    end

    # Opens output file and turns on synchronized writes (this is neede for
    # testing with Rspec).
    #
    # @param fname [String] path to the output file
    # @return [#puts] output stream
    def open_output_file(fname)
      f = File.new(fname, 'w')
      f.sync = true
      f
    end

    # Sets output stream to stdout or to a file if path to it was provided.
    #
    # @param out_dir [String] directory for output files
    # @param out_file [String] output file
    def output_stream(out_dir, out_file)
      return $stdout if out_dir.nil?
      open_output_file(out_file)
    end

    # Prints header of output log file.
    #
    # @param out_stream [#puts] stream to which output will be printed
    # @param out_file [String] name of output file
    # @param results [Hash] results of solving or statistics
    def print_header(out_stream, out_file, results)
      out_stream.puts "# #{out_file}"
      out_stream.puts "# #{results.first.keys.join('    ')}"
    end

    # Gets basenames of supplied file paths.
    #
    # @param paths [Array<String>] path to files
    # @return [Array<String>] basenames of the paths
    def file_basenames(paths)
      paths.each_with_object([]) do |path, basenames|
        basenames << File.basename(path, File.extname(path))
      end
    end

    # Construct filename for output log.
    #
    # @param output_dir [String] output directory
    # @param basename [String] basename of the output file
    # @param solving_method [String] name of solving method
    # @return [String] filename for output log
    def output_filename(output_dir, basename, solving_method)
      filename = basename + '_' + solving_method + @suffix
      return filename if output_dir.nil?
      File.join(output_dir, filename)
    end
  end
end
