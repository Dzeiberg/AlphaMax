classdef nAnHattan < DistanceMetric
   methods
       function [dist] = calc_distance(obj,a,b)
           dist = 0;
           for i = 1:size(a,2)
              if ~isnan(a(i)) && ~isnan(b(i))
                 dist = dist+abs(a(i) - b(i)); 
              end
           end
       end
   end
end