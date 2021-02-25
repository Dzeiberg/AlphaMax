# AlphaMax
Matlab methods for estimating class priors in the positive-unlabeled classification setting

## Requirements
 - deep learning toolbox
 - parallel computing toolbox

## How to run AlphaMax
[Jain et al. 2016](https://arxiv.org/pdf/1601.01944.pdf)

The main function for running AlphaMax is [runAlphaMax](alphamax/runAlphaMax.m). See [testalphamax.m](tests/testalphamax.m) for an example of how to estimate the class priors of synthetically generated datasets.

## How to run DistCurve
[Zeiberg et al. 2020](https://ojs.aaai.org//index.php/AAAI/article/view/6151)

The main function for running DistCurve is [runDistCurve](distcurve/runDistCurve.m). See [testdistcurve.m](tests/testdistcurve.m) for an example of how to use DistCurve to estimate the class priors of synthetically generated datasets.

## Contact

Daniel Zeiberg - zeiberg.d@northeastern.edu
