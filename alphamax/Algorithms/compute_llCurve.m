function [alphas, fs, out] = compute_llCurve(x, x1, varargin)
    %COMPUTE_LLCURVE Compute the likelihood curve used by AlphaMax
    %% define optional arguments
    args = inputParser;
    addOptional(args,'densityEst_fcn',@densEst_hist);
    addOptional(args,'constraints',0.01:0.01:0.99);
    addOptional(args,'consType','eq');
    addOptional(args,'parallel',false);
    addOptional(args,'num_restarts',1);
    addOptional(args,'gamma',@(x)1/length(x));
    addOptional(args,'gamma1',@(x1)1/length(x1));
    addOptional(args,'loss_str','ll_cmb2',@(x)any(strcmp({'ll_cmb',...
                                                            'll_cmb2',...
                                                            'll_cmp',...
                                                            'll_mix'},...
                                                           x)));
    
    parse(args,varargin{:});
    args = args.Results;
    %% Use gamma and gamma1 fn handles to set values
    args.gamma = args.gamma(x);
    args.gamma1 = args.gamma(x1);
    %% Calculate Density
    [dens.p,dens.p1] = args.densityEst_fcn(x,x1);
    out.dens = dens;
    %% Learn Beta
    beta_learner = BetaLearner(x, x1, dens.p, dens.p1,...
        'num_restarts',args.num_restarts,...
        'loss_str',args.loss_str,...
        'consType',args.consType,...
        'gamma',args.gamma,...
        'gamma1',args.gamma1);
    %% Init computation values
    cons=args.constraints;
    num_lbs=length(cons);
    alphas=zeros(1,num_lbs);
    ll_cmb=nan(1,num_lbs);
    ll_cmp=nan(1,num_lbs);
    ll_mix=nan(1,num_lbs);
    ll_cmb2=nan(1,num_lbs);
    fs=nan(1,num_lbs);
    objs=nan(1,num_lbs);
    iters=zeros(1,num_lbs);
    betas=nan(numkernels,num_lbs);
    init=nan(numkernels,num_lbs);
    ll_bt= @(beta)ll_beta(beta,x,x1,dens.p,dens.p1,opts);
end

