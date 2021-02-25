classdef LLCurve < handle
    %LLCURVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        args
        x
        x1
        dens
        beta_learner
        alphas
        ll_cmb
        ll_cmp
        ll_mix
        ll_cmb2
        fs
        objs
        iters
        betas
        init
        numkernels
        ll_str
    end
    
    methods
        function obj = LLCurve(x,x1,varargin)
            %% define optional arguments
            args = inputParser;
            addOptional(args,'densityEst_fcn',@densEst_hist);
            addOptional(args,'constraints',0.01:0.01:0.99);
            addOptional(args,'consType','eq');
            addOptional(args,'parallel',false);
            addOptional(args,'num_restarts',1);
            addOptional(args,'gamma',@(x)1/length(x));
            addOptional(args,'gamma1',@(x1)1/length(x1));
            addOptional(args,'loss_str','combined2',@(x)any(strcmp({'combined',...
                                                                    'combined2',...
                                                                    'component',...
                                                                    'mixture'},...
                                                                   x)));

            parse(args,varargin{:});
            args = args.Results;
            obj.x = x;
            obj.x1 = x1;
            obj.args = args;
            obj.store_ll_str();
        end
        
        function [] = store_ll_str(obj)
            loss_strs={'combined','combined2','component','mixture'};
            ll_strs={'ll_cmb','ll_cmb2','ll_cmp','ll_mix'};
            ix=strcmp(obj.args.loss_str,loss_strs);
            obj.ll_str = ll_strs{ix};
        end
        
        function [] = setGammas(obj)
            %% Use gamma and gamma1 fn handles to set values
            obj.args.gamma = obj.args.gamma(obj.x);
            obj.args.gamma1 = obj.args.gamma1(obj.x1);
        end
        
        function [] = calc_densities(obj)
            %% Calculate densities of two distributions
            [obj.dens.p,obj.dens.p1] = obj.args.densityEst_fcn(obj.x,...
                                                               obj.x1);
        end
        
        function [alphas, fs, out] = compute_llCurve(obj)
            obj.setGammas();
            obj.calc_densities();
            obj.numkernels=length(obj.dens.p.mixProp);
            obj.beta_learner = BetaLearner(obj.x, obj.x1,...
                                           obj.dens.p,obj.dens.p1,...
                                           'num_restarts',obj.args.num_restarts,...
                                           'loss_str',obj.args.loss_str,...
                                           'consType',obj.args.consType,...
                                           'gamma',obj.args.gamma,...
                                           'gamma1',obj.args.gamma1);
            obj.init_computation_values();
            if obj.args.parallel
                parfor k = 1:length(obj.args.constraints)
                    obj.parallelCalcLL(k);
                end
            else
                for k = 1 : length(obj.args.constraints)
                    iterativeCalcLL(obj,k)
                end
            end
            fs=eval(strcat('obj.',obj.ll_str));
            fs = obj.llCurve_correction(obj.alphas,fs);
            out.objs=obj.objs;
            out.betas=obj.betas;
            out.iters=obj.iters;
            out.ll_cmb=obj.ll_cmb;
            out.ll_mix=obj.ll_mix;
            out.ll_cmp=obj.ll_cmp;
            out.ll_cmb2=obj.ll_cmb2;
            out.alphas=obj.alphas;
            alphas = obj.alphas;
            out.fs=fs;
        end
        
        function [] = iterativeCalcLL(obj, k)
            beta_init = obj.init(:,k);
            if any(isnan(beta_init))
                [beta,...
                 o,...
                 alpha,iter] = obj.beta_learner.learnbeta_fcn(obj.args.constraints(k));
            else
                try
                       [beta,...
                        o,...
                        alpha,...
                        iter] = obj.beta_learner.learnbeta_fcn(obj.args.constraints(k),...
                                                               beta_init);
                catch
                    warning('optimization failed')
                end
            end
            if(isnan(o))
                error('objective nan');
            end
            obj.betas(:,k) =beta';
            obj.alphas(k)=alpha;
            obj.objs(k)=o;
            [obj.ll_cmb(k),...
             obj.ll_mix(k),...
             obj.ll_cmp(k),...
             obj.ll_cmb2(k)] = obj.ll_beta(beta);
            obj.iters(k)=iter;
            obj.update_init(k,beta);
        end
        
        function [] = update_init(obj, kk, bt)
            if kk < length(obj.args.constraints)
                bt=min(1-10^-8,bt);
                bt=max(10^-8,bt);
                if strcmp(obj.args.consType,'eq')
                    while abs(obj.args.constraints(kk+1)-sum(bt.*obj.dens.p.mixProp')) >1e-12
                        c=obj.args.constraints(kk+1)/sum(bt.*obj.dens.p.mixProp');
                        bt=min(1-10^-8,c*bt);
                    end
                elseif strcmp(obj.args.consType,'ineq')
                    bt=min(1-10^-8,bt);
                    bt=max(10^-8,bt);
                    while sum(bt.*obj.dens.p.mixProp')-obj.args.constraints(kk+1) < 1e-4
                        c=(obj.args.constraints(kk+1)+1e-3)/sum(bt.*obj.dens.p.mixProp');
                        bt=min(1-10^-8,c*bt);
                    end
                end
                obj.init(:,kk+1)=bt;
            end
        end

        function []  = parallelCalcLL(obj, constraintNum)
            [beta, o, alpha, iter] = obj.beta_learner.learnbeta_fcn(obj.args.constraints(constraintNum));
            obj.betas(:,constraintNum) = beta;
            if(isnan(o))
                error('objective nan');
            end
            obj.alphas(constraintNum)=alpha;
            obj.objs(constraintNum)=o;
            [obj.ll_cmb(constraintNum),...
             obj.ll_mix(constraintNum),...
             obj.ll_cmp(constraintNum),...
             obj.ll_cmb2(constraintNum)]=obj.ll_beta(beta);
            obj.iters(k)=iter;
        end

        function [] = init_computation_values(obj)
            cons=obj.args.constraints;
            num_lbs=length(cons);
            obj.alphas=zeros(1,num_lbs);
            obj.ll_cmb=nan(1,num_lbs);
            obj.ll_cmp=nan(1,num_lbs);
            obj.ll_mix=nan(1,num_lbs);
            obj.ll_cmb2=nan(1,num_lbs);
            obj.fs=nan(1,num_lbs);
            obj.objs=nan(1,num_lbs);
            obj.iters=zeros(1,num_lbs);
            obj.betas=nan(obj.numkernels,num_lbs);
            obj.init=nan(obj.numkernels,num_lbs);
            
        end
        
        function [ll_cmb, ll_mix, ll_cmp, ll_cmb2, out] = ll_beta(obj, beta)
            as = obj.dens.p.mixProp';
            alpha = sum(beta.*as);
            out.h0s=obj.h0(obj.x, beta);
            out.h1s=obj.h1(obj.x, beta);
            out.hs=obj.h(obj.x, alpha, beta);
            ll_mix=sum(log(obj.h(obj.x, alpha, beta)));
            if ~isempty(obj.x1)
                ll_cmp=sum(log(obj.h1(obj.x1,beta)));
                ll_cmb=ll_cmp+ll_mix;
                ll_cmb2=ll_cmp*obj.args.gamma1+ll_mix*obj.args.gamma;
            else
                ll_cmp=nan;ll_cmb=nan;ll_cmb2=nan;
            end
        end
        
        function h_val=h(obj, xx, alpha, beta)
            h_val=alpha * obj.dens.p1.pdf(xx) + (1-alpha) * obj.h0(xx,beta);
        end
        
        function hh1_val=hh1(obj, xx,bt)
            new_mp= bt .* obj.dens.p.mixProp';
            new_mp=new_mp/sum(new_mp);
            new_mix=mixture(new_mp,obj.dens.p.comps);
            hh1_val= max(new_mix.pdf(xx),10^-14); 
        end
        
        function h1_val = h1(obj,xx, beta)
            h1_val=obj.hh1(xx,beta);
        end

        function h0_val=h0(obj,xx, beta)
            h0_val=obj.hh1(xx,1-beta);
        end
        
        function fs = llCurve_correction(~,alphas,fs)
            %Corrects the log likelihood curve by enforcing it to be non increasing
            for i=1:length(fs)
                ai=alphas<alphas(i);
                fs(ai)=max(fs(ai),fs(i));
            end
        end
    end
end

