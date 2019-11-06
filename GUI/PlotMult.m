classdef PlotMult < handle
    % Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        axeshandle = [];
        multEnabled = 1;
        session;
        fig;
        
        dim;
        tail;
        handles;
        pm;
    end
    
    methods
        function obj = PlotMult(plotmanager , fig , session) 
            obj.pm = plotmanager;
            printc(mfilename, 'created');
            obj.session = session;
            obj.fig = fig;
            set(fig , 'NumberTitle' , 'off' , 'Name' , 'Multiplier Plot');
            obj.axeshandle = axes('Parent' , fig , 'DeleteFcn' , @(o,e) obj.shutdown() );
            xlabel('Real');
            ylabel('Imaginary');
            x = 0:0.001:2*pi;
            plot(cos(x) , sin(x));
            xlim([-1.4 1.4]);
            ylim([-1.4 1.4]);
            axis square;
            obj.dim = length(session.getSystem().getCoordinateList());
            obj.tail = 4;
            obj.handles = {};
            set(fig,  'DeleteFcn' , @(o,e) obj.destructor());
        end

        function [ph,th] =  outputPoint(~,~,~,~,~,~,~)
            ph = [];
            th = [];
        end
        
        function output(obj,~, ~, ~ , ~, fout , i)
            
            if (obj.multEnabled)
                printc(mfilename, 'output call');
                it = i(end);
                
                
                for j = 1:(obj.tail-1)
                    for k = 1:obj.dim;
                        set(obj.handles{k,j} , 'XData' , get( obj.handles{k,j+1}  ,'XData') , 'YData' , get( obj.handles{k,j+1}  ,'YData'));
                    end
                end
                
                for k = 1:size(fout,1)
                    rex = real(fout(k,it));
                    imy = imag(fout(k,it));
                    set(obj.handles{k,end} , 'XData' , rex , 'YData' , imy);
                end
            end
            
            drawnow expose;

        end
        
        function destructor(obj) 
            printc(mfilename, 'destructor');
            obj.pm.removeFromList(obj);
            if (ishandle(obj.fig))
                set(obj.fig , 'DeleteFcn' , []);
                delete(obj.fig)
            end
            obj.fig = [];
            delete(obj);
        end
        
        function bool =  checkLayoutValid(obj)
            printc(mfilename, 'checklayout');
            bool = ~isempty(obj.fig);
        end
        
        function bool = isAlive(obj)
            printc(mfilename, 'isalive');
           bool = 0; 
        end
        
        function f = getFigure(obj)
            printc(mfilename, 'getfigure')
            f = obj.fig;
        end
        
        function plot = makeReadyPlotObject(obj)
            printc(mfilename, 'makeReadyPlot');
            for k = 1:size(obj.handles,1)
                for j = 1:size(obj.handles,2)
                    if (ishandle(obj.handles{k,j}))
                       delete(obj.handles{k,j}); 
                    end
                end
            end
            
            
            obj.handles = cell(obj.dim , obj.tail);
            for k=1:obj.dim
                for j = 1:obj.tail
                    obj.handles{k,j} = line('Parent' , obj.axeshandle , 'XData' , [] , 'YData' , [] , 'Marker' , 'X' , 'MarkerSize' , 14 , 'Color' , max(nthroot(1 - (j/obj.tail),6) - 0.1 , 0) * [1 , 1 ,1]);
                end 
            end
            
            
            plot = obj;
        end
        function shutdown(obj)
           printc(mfilename, 'shutdown!'); 
           obj.fig = [];
        end
    end 
end

