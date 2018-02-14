# knapsack-solver
This is command-line utility for solving 0/1 knapsack problem
usingbranch-and-bound method, dynamic programming, simple heuristic
(weight/price)and fully polynomial time approximation scheme. It can measure
CPU andwall-clock time spent by solving a problem, compute relative error of
theresult and generate graphs from those values.

## Usage
Built-in usage information can be obtained by executing ```knapsack_solver```
with ```-h``` or ```--help``` option.
```
Usage: knapsack_solver OPTIONS DATASET_FILE...
    -b, --branch-and-bound           Use branch and boung method of solving
    -d, --dynamic-programming        Use dynamic programming for solving
    -f, --fptas                      Use FPTAS for solving
    -r, --heuristic                  Use brute force method of solving
    -e, --fptas-epsilon EPS          Relative error for FPTAS from range (0,1)
    -o, --output DIR                 Directory for output log files
    -g, --graphs DIR                 Directory for graphs
    -v, --version                    Show program version
    -h, --help                       Show this help message
```
At least one method of solving must be selected and one input dataset file
must be provided.
### Dataset files
Dataset input file has the following format:
```
id
capacity price_1 weight_1 price_2 weight_2 ... price_N weight_N
...
```

```id``` is non-negative integer number. It is followed by lines and each of
these lines describes one instance of 0/1 knapsack problem
instance. ```capacity``` is non-negative integer number and it is total weight
of things that can be put into the knapsack. Capacity specification is
followed by pairs of non-negative integer numbers. Each pair defines one thing
that can be put into the knapsack. The must be at least one instance defined.

### Output files
For each dataset and each selected method of solving two output files are
produced: file with results and file with statistics. When option ```-o``` is
not given, content which would be written to the files is written to stdout
separated by one blank line (results are written the first and are followed by
statistics).
Both files have the same basename which is constructed as concatenation of
input dataset file basename and method of solving. E.g. for Brand and Bound
method and ```size_4.dataset``` input dataset file the following files are
produced:
```
size_4_branch_and_bound.results
size_4_branch_and_bound.stats
```
The first two lines of the ```.results``` file begins with ```#```. Those are
comments. They are followed by lines with results of solving corresponding
instances from the input dataset file. E.g.
```
# ../test/output_logs/size_4_dynamic_programming.results
# price    config    cpu_time    wall_clock_time    relative_error
65 [1, 0, 0, 0] 0.009999999999999995 0.011663347017019987 0.0
86 [0, 0, 1, 0] 0.010000000000000009 0.006198941962793469 0.0
52 [0, 0, 1, 0] 0.009999999999999995 0.012558827002067119 0.0
```
Relative error is added only when some exact solving method is selected
(Branch and Bound or Dynamic programming).
Format of the ```.stats``` file is the similar. Example:
```
# ../test/output_logs/size_4_dynamic_programming.stats
# avg_price    avg_cpu_time    avg_wall_clock_time    avg_relative_error
67.66666666666667 0.01 0.010140371993960192 0.0
```

### Graphs
Graps are produced by Gnuplot in the directory specified by ```-g```
option. Image format is ```.png```. For every average value from statistics
(price,  cpu_time, wall_clock_time, relative_error) one graph is created. X
axis values are dataset IDs. In one graph there are multiple functions
plotted. One function for each selected method of solving, so that these
methods can be compared.

Besides from images, for each image a Gnuplot configuration file is
generated. These files have ```.gnuplot``` suffix. User can edit these files
by hand to make some additional changes and generate graphs by passing the
files to Gnuplot.

## RubyGems
This knapsack problem solver is published as a Gem at RubyGems.
https://rubygems.org/gems/knapsack_solver

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE)
file for details.
