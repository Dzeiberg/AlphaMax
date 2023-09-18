addpath(genpath("."));
% Load data from csv files
mat.X = readmatrix('data/example/example_data_pn/X.csv');
mat.y = readmatrix('data/example/example_data_pn/y.csv');
ds = Dataset(mat,"example");