# AlphaMax
Matlab methods for estimating class priors in the positive-unlabeled classification setting

[![View Positive-Unlabeled Learning Tools on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/125175-positive-unlabeled-learning-tools)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7892963.svg)](https://doi.org/10.5281/zenodo.7892963)

## Pre-requisites
### Required Toolboxes
 - deep learning toolbox
 - optimization toolbox
 - [matlab-stdlib](https://www.mathworks.com/matlabcentral/fileexchange/78673-matlab-stdlib)
### Required Software
- [svm-light](https://www.cs.cornell.edu/people/tj/svm_light/) - SVM Univariate Transform requires the files present at `~/Documents/svm_light`, but can be modified using the `SVMlightpath` argument in [transform_svm](Transforms/transform_svm.m)

### Recommended Toolboxes
- parallel computing toolbox

## Datasets
Datasets are available at [Zenodo](https://zenodo.org/record/7892963) and should be downloaded to [data/uci_ml_datasets](data/uci_ml_datasets)

## How to run AlphaMax
[Jain et al. 2016](https://arxiv.org/pdf/1601.01944.pdf)

The main function for running AlphaMax is [runAlphaMax](alphamax/runAlphaMax.m). See below for an example of how to estimate the class priors of a real data set

## How to run DistCurve
[Zeiberg et al. 2020](https://ojs.aaai.org//index.php/AAAI/article/view/6151)

The main function for running DistCurve is [runDistCurve](distcurve/runDistCurve.m). See [testdistcurve.m](tests/testdistcurve.m) for an example of how to use DistCurve to estimate the class priors of a real data set

## Example Code
### Run Estimators on Pre-processed Data
```matlab
% Load samples from the UCI gas dataset that have already been transformed
addpath(genpath("."));
load("data/uci_ml_datasets/gas.mat");
XM=ds.instances{1}.optimal.xm;
XC=ds.instances{1}.optimal.xc;
trueClassPrior=sum(ds.instances{1}.yM)/size(ds.instances{1}.yM,1);

% Run AlphaMax
%addpath("alphamax");
path_to_alphamax_estimator = "alphamax/estimators/alphamaxEstimator.mat";
[alphaMax_pred,alphaMax_out] = runAlphaMax(XM,XC,'transform','rt','useEstimatorNet',true,...
     'estimator',path_to_alphamax_estimator);

%Run DistCurve
addpath("distcurve");
path_to_distcurve_estimator = "distcurve/estimator/network.mat";
[distCurve_pred,distCurve_curve, distCurve_aucPU] = runDistCurve(XM,XC,'transform','rt',...
    'estimator',path_to_distcurve_estimator);

disp(strcat("True Class Prior: ",num2str(trueClassPrior),"; AlphaMaxNet Estimate: ",num2str(alphaMax_pred),"; DistCurve Estimate: ",num2str(distCurve_pred)))
```
### Generate dataset from PN Data
```matlab
addpath(genpath("."));
% Load data from csv files
mat.X = readmatrix('data/example/example_data_pn/X.csv');
mat.y = readmatrix('data/example/example_data_pn/y.csv');
ds = Dataset(mat,"example");
% Generate 1 PU instance from this dataset
ds.buildPUDatasets(1);
% Read Component sample and Mixture sample
XC = ds.instance{1}.optimal.xc;
XM = ds.instance{1}.optimal.xm;
trueClassPrior=sum(ds.instances{1}.yM)/size(ds.instances{1}.yM,1);
```

### Load PU Dataset
```matlab
addpath(genpath("."));
% Load Data from CSV Files
XC = readmatrix('data/example/example_data_pu/XC.csv');
XM = readmatrix('data/example/example_data_pu/XM.csv');
% Optionally Run Univariate Transforms to reduce data from d-dimensions to 1 dimension
%     Generate Feature matrix X and PU label matrix S
X = [XC;XM];
yC = ones(size(XC,1),1);
yM = zeros(size(XM,1),1);
S = [yC;yM];
transformResults = Dataset.transform_PU_data(X,S);
XC = transformResults.optimal.xc;
XM = transformResults.optimal.xm
```
## Results

Mean Absolute Error on 30 multi-dimensional datasets from [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/index.php)


| Dataset | AlphaMaxNet | AlphaMax | DistCurve |
| :---- | :---- | :---- | :--- |
| abalone | 0.2666 | 0.5134 | 0.3949 |
| activity_recogition_s1 | 0.3460 | 0.2800 | 0.3039 |
| activity_recognition_s2 | 0.0233 | 0.8467 | 0.0233 |
| adult | 0.2200 | 0.1229 | 0.1634 |
| airfoil | 0.2766 | 0.1393 | 0.1405 |
| anuran | 0.0551 | 0.1857 | 0.0623 |
| bank | 0.1805 | 0.0203 | 0.0426 |
| casp | 0.2947 | 0.0407 | 0.0991 |
| concrete | 0.3540 | 0.1729 | 0.1199 |
| covertype | 0.0973 | 0.0157 | 0.1131 |
| epileptic | 0.2314 | 0.2830 | 0.2328 |
| gas | 0.0444 | 0.0087 | 0.0350 |
| h1b | 0.0644 | 0.0356 | 0.0486 |
| housing | 0.2305 | 0.1116 | 0.0620 |
| landsat | 0.0406 | 0.0085 | 0.0569 |
| molecular biology | 0.0719 | 0.0488 | 0.0335 |
| mushroom | 0.0926 | 0.0231 | 0.0118 |
| pageblock | 0.0856 | 0.0184 | 0.0640 |
| parkinsons | 0.1164 | 0.0367 | 0.0603 |
| pendigit | 0.0178 | 0.0202 | 0.0331 |
| pima | 0.1576 | 0.1895 | 0.0810 |
| shuttle | 0.1238 | 0.1572 | 0.2383 |
| smartphone | 0.0270 | 0.0273 | 0.0727 |
| spambase | 0.1741 | 0.0422 | 0.0166 |
| thyroid | 0.0377 | 0.6333 | 0.0377 |
| transfusion | 0.0937 | 0.1397 | 0.0688 |
| waveform | 0.0513 | 0.1312 | 0.0270 |
| waveformnoise | 0.0740 | 0.0588 | 0.0263 |
| wilt | 0.0301 | 0.3862 | 0.0332 |
| wine | 0.2073 | 0.1297 | 0.0874 |
|  |  |  |  |
| Overall | 0.1362 | 0.1609 | 0.0930 |

## Related Repositories
[DistCurve Python Implementation](https://github.com/Dzeiberg/dist_curve)

## Contact

Daniel Zeiberg - zeiberg.d@northeastern.edu
