classdef maeLoss < nnet.layer.RegressionLayer
    % calculate MAE.

%     properties (Learnable)
%         % Layer learnable parameters (dummy for consistency);
%     end
    
    methods
        function layer = maeLoss(name) 
            % Set layer name.
            layer.Name = name;

            % Set layer description.
            layer.Description = "Zero One Relu Layer";
        
        end
        
        function loss = forwardLoss(layer, Y, T)
            loss = sum(abs(Y - T))/numel(Y);
        end
    end
end