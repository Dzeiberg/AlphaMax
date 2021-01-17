classdef reLuZeroOneLayer < nnet.layer.Layer
    % ReLU restricted to the range [0,1].

%     properties (Learnable)
%         % Layer learnable parameters (dummy for consistency);
%     end
    
    methods
        function layer = reLuZeroOneLayer(name) 
            % layer = zeroOneReluLayer(name) creates a PReLU layer
            % ReLu layer with max value 1
            % Set layer name.
            layer.Name = name;

            % Set layer description.
            layer.Description = "Zero One Relu Layer";
        
        end
        
        function Z = predict(layer, X)
            Z = min(max(0,X),1);
        end
    end
end