classdef CommanderDiagramPlot < PlotPreviewer
   properties
       listener1;
       listener2;
   end
    
    methods
        function obj = CommanderDiagramPlot(session , commandmodel , sideindex , dimension)
            obj@PlotPreviewer(session , PlotPreviewer.DIAGRAM , commandmodel.getCurveManager(sideindex) , dimension);
        
            obj.listener1 = commandmodel.addlistener('diagramSelectionChanged' , @(o,e) obj.updateSelection(o , e, sideindex));
            obj.listener2 = commandmodel.addlistener('diagramListChanged' , @(o,e) obj.setPlot( commandmodel.getCurveManager(sideindex)) );
        end
        function updateSelection(obj, commandmodel , event, sideindex)
           if (event.index == sideindex)
            obj.setPlot(PlotPreviewer.DIAGRAM,  commandmodel.getCurveManager(sideindex)); 
           end
        end
        
        function destructor(obj)
            delete(obj.listener1);
            delete(obj.listener2);
            destructor@PlotPreviewer(obj);
          
            
        end
        
    end
    
    
    
    
end