% test prep
addpath("../distcurve/");
addpath("../distcurve/distanceMetrics/");
pos = [1];
mix = [10,4,6,8,2];
%% Test 1: Default Arguments
constructor = CurveConstructor(pos.', mix.');
distances = constructor.makeSingleCurve();
m = pdist2(pos.',mix.');
assert(all(ismember(distances, m)));
assert(all(distances == [1,3,5,7,9]));
%% Test 2: Premade metric
constructor = CurveConstructor(pos.', mix.','distanceMetric','manhattan');
distances = constructor.makeSingleCurve();
m = pdist2(pos.',mix.');
assert(all(ismember(distances, m)));
assert(all(distances == [1,3,5,7,9]));
%% Test 3: Custom Metric
constructor = CurveConstructor(pos.', mix.','distanceMetric',nAnHattan());
distances = constructor.makeSingleCurve();
m = pdist2(pos.',mix.');
assert(all(ismember(distances, m)));
assert(all(distances == [1,3,5,7,9]));
%% Test 4: Make Curve
constructor = CurveConstructor(pos.', mix.','distanceMetric','manhattan', 'numCurvesToAverage',2);
distances = constructor.makeDistanceCurve();
m = pdist2(pos.',mix.');
assert(all(distances == prctile([1,3,5,7,9],0:99)));
