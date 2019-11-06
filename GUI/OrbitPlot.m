classdef OrbitPlot < handle
    properties
        
        plotter        
        
        lastpoint
        labellist = {};
    end
    properties(Constant)
       CO = {'XData' , 'YData' , 'ZData' }; 
    end
    
    methods
        function obj = OrbitPlot(plotter)
            obj.plotter = plotter;
            if getSwitch('orbitdrawlines')
                obj.plotter.plotops = {};
            else
                obj.plotter.plotops = {'LineStyle' , 'none'};
            end
        end
        

        function output(obj , varargin)
           obj.plotter.output(varargin{:}); 
           t = get(obj.lastpoint);
           delete(obj.lastpoint);
           %ALERT: meer opties overplaatsen
           line('XData' , t.XData , 'YData' , t.YData , 'ZData' , t.ZData , 'Color' , t.Color , 'ButtonDownFcn' , t.ButtonDownFcn, 'Marker' , t.Marker , 'Parent' , t.Parent);
           
        end
        
        function outputPoint(obj , varargin)
           [obj.lastpoint , lbl] = obj.plotter.outputPoint(varargin{:}); 
           
           if getSwitch('orbitdrawpointnumbers')
    %            obj.plotconf.fitAxis();
                d = axis(obj.plotter.axeshandle);
    %            
    %            for i = 1:2:length(d)
    %                 marg = 0.08 * (d(i+1) - d(i));
    %                 d(i) = d(i) - marg;
    %                 d(i+1) = d(i+1) + marg;
    %            end
    %           axis(obj.plotter.axeshandle, d);

               obj.labellist{end+1} = lbl;
               adjustlabels( obj , d );
           end
        end
        
        
        function adjustlabels(obj , d )
            
            lastdat = get(obj.labellist{end} , 'UserData');
            len = length(obj.labellist);
            for i = length(obj.labellist):-1:1
                pos = [0 0 0];
                dat = get(obj.labellist{i} , 'UserData');
                
                if ((len == i) || (norm(lastdat - dat) > sqrt(eps)))
                    for j = 1:length(dat)
                        pos(j) = dat(j) + 0.012*(d(2*j) - d(2*j -1));
                    end
                    set(obj.labellist{i},'Position' , pos);
                else

                    delete(obj.labellist{i})
                    obj.labellist(i) = [];
                end
            end
        end
        
                        
    end
    
end


