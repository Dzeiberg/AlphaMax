Transforms

This directory contains methods for applying class prior preserving transforms to multi-dimensional data.

To train an ensemble of probabilistic classifiers, use transform_bagging.m
	Given the features matrix, PU labels vector, and a function handle that returns an instance
	of a Transform (NeuralNetwork, RegressionTree, or a custom transform), predict PU posterior
	probabilities and AUCPU. See Transform.m for the template that should be used for custom transforms

To train an SVM using k-fold cross validation, see transform_svm.m
	This file can be used as a template for a script for training any transform using k-fold CV

applyTransform.m is the starting point from which you can apply one of the 3 built-in transforms
with their optional arguments.


