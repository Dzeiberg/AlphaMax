all_errors = struct();
for dsnum = 1:numel(setnames)
    sn = setnames{dsnum};
    distnames= fieldnames(dsets.(sn).features);
    for distnum = 1:numel(distnames)
       dn = distnames{distnum}; 
       dnerased = erase(dn,"_l2");
       if isfield(all_errors,dnerased)
           all_errors.(dnerased) = [all_errors.(dnerased);dsets.(sn).abserrs.(dn)];
       else
           all_errors.(dnerased) = dsets.(sn).abserrs.(dn);
       end
    end
end


distnames= fieldnames(all_errors);
for distnum = 1:numel(distnames)
    disp(distnames{distnum})
%     disp(numel(all_errors.(distnames{distnum})))
    disp(mean(all_errors.(distnames{distnum})))
end