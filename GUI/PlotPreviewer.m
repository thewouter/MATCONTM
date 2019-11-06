classdef PlotPreviewer < handle
    %PLOTPREVIEWER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        plotconf
        type
        toPlotObject
        listener
        fig
    end
    properties(Constant)
       DIAGRAM = 1;
       CURVE = 2;
    end
    
    methods
        
        function obj = PlotPreviewer(session , type, toPlotObject , dim)
            obj.fig = figure('DeleteFcn' , @(o,e) obj.destructor());
            obj.plotconf = PlotConfiguration(session , obj.fig, dim);
            obj.plotconf.setAutoFit(true);
            obj.plotconf.setAutoRedraw(true);
            
            obj.type = type;
            obj.toPlotObject = toPlotObject;
            obj.listener = obj.plotconf.addlistener('layoutChanged' , @(o,e) obj.redraw());
            obj.draw();
            PlotConfiguration.installPreviewMenu( obj.fig ,  obj.plotconf , session);
        end
        
        function redraw(obj)
            if (obj.plotconf.getAutoRedraw())
               obj.draw(); 
            end
        end
        
        function setPlot( obj, type , toPlotObject)
            obj.type = type;
            obj.toPlotObject = toPlotObject;            
            obj.draw();
        end
        
        function draw(obj)
            if (isempty(obj.toPlotObject)), return; end
            
            if (obj.type == obj.CURVE)
                obj.plotconf.plotCurve(obj.toPlotObject);
                
                printc(mfilename , 'redraw: Curve');
                
            else %obj.type == obj.DIAGRAM
                obj.plotconf.plotDiagram(obj.toPlotObject);
                printc(mfilename , 'redraw: Diagram');
                
            end
            if (obj.plotconf.getAutoFit())
                printc(mfilename , 'AUTOFIT called')
                obj.plotconf.fitAxis();
                obj.plotconf.setAutoFit(true);
                printc(mfilename, 'autofit set back to true');
            end
            
        end
        
        
        function destructor(obj)
           delete(obj.listener);
           delete(obj); 
        end
    end
    
end

