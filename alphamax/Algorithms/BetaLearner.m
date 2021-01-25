classdef BetaLearner < handle
    %BETALEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mixture_sample
        component_sample
        mixture_density
        component_density
        numkernels
        args
        hs
        avec
        compSS
        mixSS
        hxcomp
        hxmix
        wtcomp
        fhatx
        diffmatmix
        loss_fcn
        options
        ismix
        A
        b
        Aeq
        beq
        beta
        f
        alpha
        iter
    end
    
    methods
        function obj = BetaLearner(mixture_sample,component_sample,...
                                   mixture_density, component_density,...
                                   varargin)
            %INPUTS
            %    - mixture samples: column vector of univariate sample from mixture.
            %    - component samples: column vector of univariate sample from component.
            %    - mixture_density: The estimate of the mixture density
            %         expressed as a $k-component$ mixture;
            %         object of class mixture.
            %    - component_density: The estimate of the component density;
            %          it is a object of a class for which pdf method is
            %          defiend, usually a mixture object or a probability
            %          ditribution object.
            obj.mixture_sample = mixture_sample;
            obj.component_sample = component_sample;
            obj.mixture_density = mixture_density;
            obj.component_density = component_density;
            obj.numkernels = length(mixture_density.mixProp);
            args = inputParser;
            addOptional(args,'num_restarts',1);
            addOptional(args,'gamma',1/length(mixture_sample));
            
            addOptional(args,'gamma1',1/length(component_sample));
            v = @(x) obj.verifyLossString(x,length(component_sample));
            addOptional(args,'loss_str','combined2',v);
            addOptional(args,'consType','eq');
            addOptional(args,'regwgt',0);
            parse(args,varargin{:});
            obj.args = args.Results;
            obj.loss_str_2_loss_fcn();
            obj.ismix = strcmp('ll_mix',obj.args.loss_str);
            obj.initialize_values();
        end
        
        function [] = loss_str_2_loss_fcn(obj)
            loss_strs={'combined','combined2','component','mixture'};
            loss_fcns={@combinedLoss,@combined2Loss,@componentLoss,@mixtureLoss};
            obj.loss_fcn=loss_fcns{strcmp(obj.args.loss_str,loss_strs)};
        end
        function [] = initialize_values(obj)
            % Get all the components of the mixture model
            obj.hs = obj.mixture_density.comps;
            % avec conatins w_i
            obj.avec = obj.mixture_density.mixProp';
            % ensure w sum to 1
            obj.avec = obj.avec / sum(obj.avec);
            obj.numkernels = length(obj.avec);
            obj.mixSS = length(obj.mixture_sample);
            obj.compSS = length(obj.component_sample);
            %to store \kappa_i values on the component sample.
            if ~obj.ismix
                obj.hxcomp = zeros(obj.compSS,obj.numkernels);
            end
            %to store \kappa_i values on the mixture sample.
            obj.hxmix = zeros(obj.mixSS, obj.numkernels);
            for kernNum = 1:obj.numkernels
                if ~obj.ismix
                    obj.hxcomp(:,kernNum) = pdf(obj.hs{kernNum},...
                        obj.component_sample);
                end
                obj.hxmix(:,kernNum) = pdf(obj.hs{kernNum},...
                    obj.mixture_sample);
            end
            %wtcomp contains w_i\kappa_i evaluated on component sample.
            if ~obj.ismix
                obj.wtcomp = repmat(obj.avec',obj.compSS,1).*obj.hxcomp;
            end
            %fhatx contains estimate of f_1 evaluted on mixture sample.
            obj.fhatx = pdf(obj.component_density,obj.mixture_sample);
            obj.diffmatmix = repmat(obj.fhatx,1,obj.numkernels) - obj.hxmix;
            % add regularizer term to the loss function.
            if obj.args.regwgt ~= 0
                obj.loss_fcn = @(beta)obj.regularized_loss(beta);
            end
            obj.options = optimoptions('fmincon','GradObj','on',...
                'Display','off');
        end

        function [beta, f, alpha, iter] = learnbeta_fcn(obj,varargin)
            p = inputParser;
            addOptional(p,'alpha_cons',0);
            addOptional(p,'beta_init',"none");
            parse(p,varargin{:});
            
            obj.A = [-1 * eye(obj.numkernels);eye(obj.numkernels)];
            obj.b = [zeros(obj.numkernels,1);ones(obj.numkernels,1)];
            % fmin_BFGS enforces Ax >= b, rather than fmincons Ax <= b
            obj.A = -1 * obj.A;
            obj.b = -1 * obj.b;
            alphas = zeros(1,obj.args.num_restarts);
            fs = zeros(1,obj.args.num_restarts);
            iters=zeros(1,obj.args.num_restarts);
            betas=zeros(obj.numkernels,obj.args.num_restarts);
            for rr = 1:obj.args.num_restarts
                [beta_init] = obj.betaInitAdjust(p.Results.alpha_cons,...
                                                      p.Results.beta_init);
                [beta_i,f_i,iter_i,~] = obj.fmincon_caller(beta_init);
                betas(:,rr) =beta_i;
                alphas(rr)=obj.avec'*beta_i;
                fs(rr)=f_i;
                iters(rr)=iter_i;
            end
            [f,ix_min]=min(fs);
            beta=betas(:,ix_min);
            alpha=alphas(ix_min);
            iter=iters(ix_min);
        end
        
        function [beta_init] = betaInitAdjust(obj, alpha_cons,beta_init)
            if strcmp(obj.args.consType, 'ineq')
                obj.A = [obj.A; obj.avec'];
                obj.b = [obj.b; alpha_cons];
                if isstring(beta_init) && strcmp(beta_init,'none')
                    beta_init = rand(obj.numkernels,1);
                    beta_init = alpha_cons + (1-alpha_cons-10^-7)*beta_init;
                end
            elseif strcmp(obj.args.consType,'eq')
                obj.Aeq = obj.avec';
                obj.beq = alpha_cons;
                if isstring(beta_init) && strcmp(beta_init,'none')
                    beta_init = repmat(alpha_cons, obj.numkernels, 1);
                end
            end
        end
        function [beta,f,iter,flag]= fmincon_caller(obj, beta_init)
            if strcmp(obj.args.consType,'eq')
                [beta,f,flag,output] = fmincon(@(x)obj.loss_fcn(obj,x),...
                    beta_init,...
                    -obj.A,...
                    -obj.b,...
                    obj.Aeq,...
                    obj.beq,[],[],[],obj.options);
            elseif strcmp(obj.args.consType,'ineq')
                [beta,f,flag,output] = fmincon(@(x)obj.loss_fcn(obj,x),...
                    beta_init,...
                    -obj.A,-obj.b,[],[],[],obj.options);
            end
             iter=output.iterations;
        end
        %% Auxiliary Functions
        function [valid] = verifyLossString(~, loss, compSS)
            valid = any(strcmp({'combined',...
                            'combined2',...
                            'component',...
                            'mixture'},...
                        loss));
           if (compSS == 0) && ~strcmp(loss,'mixture')
               valid = false;
               warning("invalid loss function; loss must be set to ll_mix if component sample is not provided");
           end
        end
        function [f,g] = regularized_loss(obj, beta)
            [f1,g1] = obj.loss_fcn(beta);
            [f2,g2] = obj.maxalpha(beta);
            f = f1+f2+f3;
            g = g1+g2+g3;  
        end
    
        function [f,g] = combinedLoss(obj,beta)
            [f1,g1] = obj.componentLoss(beta);
            [f2,g2] = obj.mixtureLoss(beta);
            f = f1+f2;
            g = g1+ g2;
        end

        function [f,g] = combined2Loss(obj,beta)
            [f1,g1] =  obj.componentLoss(beta);
            [f2,g2] =  obj.mixtureLoss(beta);
            f = obj.args.gamma1*f1+ obj.args.gamma*f2;
            g = obj.args.gamma1*g1+obj.args.gamma*g2;
        end
    
        function [f,g] = componentLoss(obj, beta)
            % For all x, computes fhat(x) =
            % log(sum_i b_i a_i h_i(x)) - log(sum_i b_i a_i)
            % then returns -fhat
            [f1,g1] = obj.lossFhat_convex(beta);
            [f2,g2] = obj.lossFhat_concave(beta);
            f = f1+f2;
            g = g1+g2;
        end
    
        function [f,g] = lossFhat_concave(obj, beta)
        % For all x, computes log(sum_i b_i a_i)
        % the concave part of lossFhat
        % log(sum_i b_i a_i)
            sbavec = sum(beta.*obj.avec);
            f =obj.compSS* log(sbavec);
            g = obj.compSS* obj.avec/sbavec;
        end
    
        function [f,g] = lossFhat_convex(obj, beta)
        % For all x, computes -log(sum_i b_i a_i h_i(x))
        % the convex part of lossFhat
        % 1/nsamples sum_t log(sum_i b_i a_i h_i(x))
            bavec = beta.*obj.avec;
            ksum = sum(repmat(bavec',obj.compSS,1).*obj.hxcomp, 2);
            ksum(ksum < 1e-5) = 1e-5;
            f = sum(log(ksum));
            g = sum(obj.wtcomp./repmat(ksum,1,obj.numkernels),1)';
            % The above was all for maximizing, but want to minimize
            f = -f;
            g = -g;      
        end    
    
        function [f, g] = mixtureLoss(obj, beta)
        % For all x, computes f(x) + sum_i b_i a_i (fhat(x) - h_i(x)) 
        % = sum_i a_i h_i(x) + sum_i b_i a_i (fhat(x) - h_i(x)) = 
        % = sum_i a_i (1 - b_i) h_i(x) + sum_i b_i a_i fhat(x)
        % Get sum_i a_i (1 - b_i) h_i(x) + sum_i b_i a_i fhat(x)
            ksum = sum(repmat(((ones(obj.numkernels,1)-beta).*obj.avec)',...
                              obj.mixSS,1).*obj.hxmix, 2) + ...
                   sum(beta.*obj.avec)*obj.fhatx;   
            % For numerical reasons, cap ksum at some small positive value
            ksum(ksum < 1e-5) = 1e-5;
            f = sum(log(ksum));
            g = obj.avec.*sum(obj.diffmatmix./repmat(ksum,1,obj.numkernels),1)';
            % The above was all for maximizing, but want to minimize
            f = -f;
            g = -g;
        end
    
        function [f,g] = maxalpha(obj,beta)
            % Add the regularizer which pushes alpha to 1
            % maximize f(betavec) = <betavec,avec>, so minimize -<betavec,avec>
            f = -obj.args.regwgt*sum(beta.*obj.avec);
            g = -obj.args.regwgt.*obj.avec; 
        end

%     function d= f1Dens(obj,betavec,x)
%         d= obj.fiDens(betavec,x);
%     end
% 
%     function d= f0Dens(obj, betavec,x)
%         d= obj.fiDens(1-betavec,x);
%     end
%     function d= fiDens(obj, wt,x)
%         wtavec = wt.*obj.avec;
%         nx=length(x);
%         hx=hFun(x);
%         ksum = sum(repmat(wtavec',nx,1).*hx, 2);
%         d= ksum/sum(wtavec);
%     end
%     function d= mixDens(betavec,x)
%         hx=hFun(x);
%         nx=length(x);
%         fx=pdf(p1,x)';
%         d= sum(repmat(((ones(numkernels,1)-betavec).*avec)', ...
%                           nx,1).*hx, 2) + ...
%                sum(betavec.*avec)*fx; 
%     end

%     function hx=hFun(x)
%         nx=length(x);
%         hx = zeros(nx, numkernels);
%         for ii = 1:numkernels
%             hx(:,ii) = pdf(hs{ii},x); % get value for h_i in the mixture
%         end
%     end
    end
end


