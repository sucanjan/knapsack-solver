require 'gnuplot'

module KnapsackSolver
  # This class provides support for making graphs from statistics of datasets
  # solving results. It uses Gnuplot and also generates a Gnuplot config file
  # for each generated graph.
  class GraphPrinter
    # Initializes printer for graph data (graphs, Gnuplot config files).
    #
    # @param dataset_filenames [Array<String>] dataset filenames
    # @param stats [Hash] statistics of results
    # @param out_dir [String] statistics of results to print
    def initialize(dataset_filenames, stats, out_dir)
      @dataset_basenames = file_basenames(dataset_filenames)
      @stats = stats
      @out_dir = out_dir
    end

    # Create graphs from statistics and Gnuplot configuration files.
    def print
      stats_to_datasets.each do |title, ds|
        ofn = File.join(@out_dir, title + '.png')
        plot(title, ds, ofn)
      end
    end

    protected

    # Create graph.
    #
    # @param title [String] title of the graph
    # @param data [Array<Gnuplot::DataSet>] Gnuplot datasets to plot
    # @param filename [String] path to the output image file
    def plot(title, data, filename)
      Gnuplot.open do |gp|
        Gnuplot::Plot.new(gp, &plot_config(title, 'dataset', 'y', data, filename))
      end
      File.open(File.join(File.dirname(filename), File.basename(filename, '.png') + '.gnuplot'), 'w') do |gp|
        Gnuplot::Plot.new(gp, &plot_config(title, 'dataset', 'y', data, filename))
      end
    end

    # Creates Gnuplot datasets from statistics.
    #
    # @return [Array<Gnuplot::DataSet>] Gnuplot datasets created from the statistics.
    def stats_to_datasets
      graphs = @stats.values.first.values.first.first.keys
      x_data = @stats.keys
      datasets(graphs, x_data)
    end

    # Creates Gnuplot datasets from statistics.
    #
    # @param graphs [Array] array of graph titles
    # @param x_data [Array] array of X axis values
    def datasets(graphs, x_data)
      graphs.each_with_object({}) do |g, gnuplot_datasets|
        @stats.each_value do |s|
          gnuplot_datasets[g.to_s] = s.each_key.with_object([]) do |method, o|
            o << plot_dataset(method.to_s, x_data, @stats.map { |_, v| v[method].first[g] })
          end
        end
      end
    end

    # Create dataset from provided title, X axis data and Y axis data.
    #
    # @param title [String] Gnuplot dataset title
    # @param x_data [Array] Array of X values
    # @param y_data [Array] Array of Y values
    # @return [Gnuplot::DataSet] Gnuplot dataset.
    def plot_dataset(title, x_data, y_data)
      Gnuplot::DataSet.new([x_data, y_data]) { |ds| ds.title = escape_gnuplot_special_chars(title) }
    end

    # Creates Gnuplot plot configuration (configuration text lines).
    #
    # @param title [String] graph title
    # @param xlabel [String] label of X axis
    # @param ylabel [String] label of Y axis
    # @param plot_datasets [Array<Gnuplot::DataSet>] Gnuplot datasets for plotting
    # @param out_file [String] output file
    # @return [lambda] Lambda for setting plot configuration.
    def plot_config(title, xlabel, ylabel, plot_datasets, out_file)
      lambda do |plot|
        plot.term('png')
        plot.output(out_file)
        plot.title("'#{escape_gnuplot_special_chars(title)}'")
        plot.ylabel("'#{escape_gnuplot_special_chars(ylabel)}'")
        plot.xlabel("'#{escape_gnuplot_special_chars(xlabel)}'")
        plot.key('outside')
        plot.data = plot_datasets
      end
    end

    # Escapes Gnuplot special characters.
    #
    # @param str [String] a string
    # @return [Strnig] the string with Gnuplot special chars escaped
    def escape_gnuplot_special_chars(str)
      # underscore means subscript in Gnuplot
      str.gsub('_', '\_')
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
  end
end
