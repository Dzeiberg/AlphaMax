files = dir("/ssdata/ClassPriorEstimationPrivate/data/rawDatasets/*.mat");
for fileNum = length(files):-1:2
    %% Generate Dataset with transforms
    disp([fileNum,length(files)])
    mat = load(strcat(files(fileNum).folder,"/",files(fileNum).name));
    ds = Dataset(mat,files(fileNum).name);
    tic;ds.buildPUDatasets(10,'debug',false);toc;
    save(strcat("data/datasets/",files(fileNum).name), 'ds')
end