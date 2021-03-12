function [] = transformDataFile()
    files = dir("/ssdata/ClassPriorEstimationPrivate/data/realData/*/*.mat");
    for filenum = 1:length(files)
        if ~contains(files(filenum).name,"_")
            try
                ds = load(strcat(files(filenum).folder,"/",files(filenum).name));
                data = getData(ds);
                save(strcat("data/datasets_pedja/",files(filenum).name),"data");
            catch
                disp(strcat("skipping ",files(filenum).name))
            end
            
        end
    end
end

function [data] = getData(ds)
    optimal = getOptimalTransform(ds);
    for inst = 1:size(ds.DX,2)
        scores = ds.(strcat("g_",optimal(inst))){inst};
        posScores = scores(ds.DY{inst} == 1);
        if size(posScores,1) ~= 1
            posScores = posScores';
        end
        unlabeledScores = scores(ds.DY{inst} == 0);
        if size(unlabeledScores,1) ~= 1
            unlabeledScores = unlabeledScores';
        end
        data.xP{inst} = posScores;
        data.xU{inst} = unlabeledScores;
    end
    data.alpha = ds.n1 / ds.nf;
end

function [optimal] = getOptimalTransform(ds)
    optimal = [];
    transformNames = ["rt","nn1","nn2","nn3","svm1","svm2"];
    for inst = 1:size(ds.auc_nn1,2)
        [~,arg] = max([ds.auc_rt(1,inst),...
            ds.auc_nn1(1,inst),...
            ds.auc_nn2(1,inst),...
            ds.auc_nn3(1,inst),...
            ds.auc_svm1(inst,2),...
            ds.auc_svm2(inst,2)]);
        optimal = [optimal;transformNames(arg)];
    end
end

