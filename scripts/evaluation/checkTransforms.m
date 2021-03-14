% datasets = dir("data/datasets/*.mat");
% wins = struct('rt',0,'nn1',0,'nn5',0,'nn25',0,'svm1',0,'svm2',0);
% aucs = [];
% for dsnum = 1:length(datasets)
%     ds = load(strcat(datasets(dsnum).folder,"/",datasets(dsnum).name));
%     ds = ds.ds;
%     for inst = 1:length(ds.instances)
%         wins.(ds.instances{inst}.optimal.name) = wins.(ds.instances{inst}.optimal.name) + 1;
%         aucs = [aucs;ds.instances{inst}.optimal.aucpu];
%     end
% end

datasets = dir("/ssdata/ClassPriorEstimationPrivate/data/realData/*/*.mat");
for dsnum = 1:length(datasets)
    try
    if ~contains(datasets(dsnum).name,"_")
    ds = load(strcat(datasets(dsnum).folder,"/",datasets(dsnum).name));
    disp(datasets(dsnum).name)
    ds2 = load(strcat("data/datasets/",datasets(dsnum).name));
    ds2 = ds2.ds;
    
    vals = cellfun(@(inst) inst.optimal.aucpu,ds2.instances,'UniformOutput',false);
    disp({"mine",mean(cell2mat(vals))})
    disp({"rt",mean(ds.auc_rt)})
    disp({"nn1",mean(ds.auc_nn1)})
    disp({"nn2",mean(ds.auc_nn2)})
    disp({"nn3",mean(ds.auc_nn3)})
    disp({"svm1",mean(ds.auc_svm1(:,2))})
    disp({"svm2",mean(ds.auc_svm2(:,2))})
    end
    catch exc
        disp("skipping")
    end
end