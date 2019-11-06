classdef CommanderCurvePlot < PlotPreviewer
    properties
        listener1;
        listener2;
        listener3;
        sideindex = -1;
        curveindex = -1;
    end
    
    methods
        function obj = CommanderCurvePlot(session , commandmodel , startsideindex , dimension)
            obj@PlotPreviewer(session , PlotPreviewer.CURVE , commandmodel.getCurve(startsideindex)  , dimension);
            
            obj.listener1 = commandmodel.addlistener('diagramSelectionChanged',  @(o,e) obj.onDiagramChanged(o,e) );
            obj.listener2 = commandmodel.addlistener('diagramListChanged' ,      @(o,e) obj.cleanup());
            obj.listener3 = commandmodel.addlistener('curveSelection',  @(o,e) obj.setCurve(o , e));
        end
        
        function onDiagramChanged(obj, commandmodel , event)
            if (event.index == obj.sideindex)
                obj.cleanup();
            end
        end
        
        function setCurve(obj,commandmodel, event )
            sideindex = event.index;
            curveindex = commandmodel.getSelectedCurve(sideindex);
            if ((obj.sideindex == sideindex) && (obj.curveindex == curveindex))
%                disp('replot avoided');
                return;
            else
                obj.sideindex = sideindex;
                obj.curveindex = curveindex;
                obj.curveindex = commandmodel.getSelectedCurve(sideindex);
                if (commandmodel.isValidCurve(sideindex))
                    obj.toPlotObject = commandmodel.getCurve(sideindex);
                    obj.draw();
                else
                    obj.toPlotObject = [];
                    obj.plotconf.clearAx();
                end
            end
        end
        
        function cleanup(obj)
            obj.toPlotObject = [];
            obj.plotconf.clearAx();
        end
        function destructor(obj)
            delete(obj.listener1);
            delete(obj.listener2);
            delete(obj.listener3);
            destructor@PlotPreviewer(obj);
        end
    end
    
    
end