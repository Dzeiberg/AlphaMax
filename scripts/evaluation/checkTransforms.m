datasets = dir("data/datasets/*.mat");
wins = struct('rt',0,'nn1',0,'nn5',0,'nn25',0,'svm1',0,'svm2',0);
aucs = [];
for dsnum = 1:length(datasets)
    ds = load(strcat(datasets(dsnum).folder,"/",datasets(dsnum).name));
    ds = ds.ds;
    for inst = 1:length(ds.instances)
        wins.(ds.instances{inst}.optimal.name) = wins.(ds.instances{inst}.optimal.name) + 1;
        aucs = [aucs;ds.instances{inst}.optimal.aucpu];
    end
end