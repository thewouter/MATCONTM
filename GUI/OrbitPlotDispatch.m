classdef OrbitPlotDispatch
    
    properties
        plotlist = {};
    end
    
    methods 
        function obj = OrbitPlotDispatch()
        global sOutput    
            obj.plotlist = sOutput.releasePlotList();
            for i = 1:length(obj.plotlist)
               obj.plotlist{i} = OrbitPlot( obj.plotlist{i}); 
            end
            
        end
        function outputPoint(obj , varargin)
           for i = 1:length(obj.plotlist)
              obj.plotlist{i}.outputPoint(varargin{:}); 
           end
        end
        
        function output(obj , varargin)
           for i = 1:length(obj.plotlist)
              obj.plotlist{i}.output(varargin{:}); 
           end           
        end
        
    end
    
    
    
    
    
    
end