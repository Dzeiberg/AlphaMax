% test vectors
a = [1,3,2];
b = [-1,4,3];

%% Test 1: Manhattan Distance
manhattan = Minkowski(1);
assert(manhattan.calc_distance(a,b) == 2+1+1)

%% Test 2: Euclidian Distance
euclidian = Minkowski(2);
assert(euclidian.calc_distance(a,b) == ((2^2)+(1^2)+(1^2))^.5);

%% Test 3: Cosine Distance
cosine = Cosine();
assert(cosine.calc_distance(a,b) == 1 - (17/(2*91^.5)));

%% Test 4: Yang 1
yang1 = Yang(1);
assert(abs(yang1.calc_distance(a,b) - .444444) < 0.01);

%% Test 5: Yang 2
yang2 = Yang(2);
assert(abs(yang2.calc_distance(a,b) - 0.314269) < 0.0001);

%% Test 6: Custom Distance Metric
nanhattan = nAnHattan();
c = [1,nan, 3];
assert(nanhattan.calc_distance(a,c) == 1);
