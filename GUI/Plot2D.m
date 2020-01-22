classdef Plot2D
    %PLOT2D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        axeshandle
        xmap
        ymap

        plotops = {};
        plotconfig;
        group;

    end
    properties(Constant)
       COLORS = {'blue' , 'black' , 'magenta' , 'green' , 'cyan'};
      
	

    end
    
    methods
        function obj = Plot2D(axeshandle, plotconfig , xmap , ymap)
            obj.axeshandle = axeshandle;
            obj.xmap = xmap;
            obj.ymap = ymap;
            obj.plotconfig = plotconfig;
            
            

            
            obj.group = hggroup('Parent' , obj.axeshandle );
            %
        end

        function [ph,th] =  outputPoint(obj,  xout, hout, fout , i , plotops, pointmsg)
            it = i(end);            
            x = obj.xmap(xout, hout, fout, it);
            y = obj.ymap(xout, hout, fout, it);
            pointmsg = [num2str(i) ': ' pointmsg];
            ph = line([[] x],[[] y] , 'Parent' , obj.group ,  obj.plotconfig.orbitpoint{:} , 'ButtonDownFcn' , @(o,e) disp(pointmsg), plotops{:});
            
            if getSwitch('orbitdrawpointnumbers')
                d = axis(obj.axeshandle);
                skew = 0.012*[d(2)-d(1) d(4)-d(3)];     
                th = text(x+skew(1),y+skew(2), num2str(i) , 'Parent' ,obj.axeshandle, 'ButtonDownFcn' , @(o,e) disp(pointmsg), obj.plotconfig.label{:} , 'UserData', [x y]);
            else
                th = -1;
            end
            
        end
        
        function output(obj, session, xout, s , hout, fout , i)

            it = i(end);
            if i(end)>1, jj = 1;else jj = 0;end

            
            %axes(obj.axeshandle);
            %hold on
            
            x0 = obj.xmap(xout, hout, fout , it-jj);
            x1 = obj.xmap(xout, hout, fout, it);
            y0 = obj.ymap(xout, hout, fout , it-jj);
            y1 = obj.ymap(xout, hout, fout, it);
            
            if ((numel(x0) ~= 1) && strcmp(session.currentCurveType.getLabel(), 'IC'))
                PIC(session.currentcurve, x0(1:end-1), x0(end), y0(end), obj);
            else
                line([x0 x1] , [y0 y1] , 'Parent' , obj.group  , obj.plotconfig.curve{:}, obj.plotops{:}); 
            end
            
            
            
            if ((it > 2) && ( s.index == (it - 1) ))
                
                x = obj.xmap(xout, hout, fout , it-1);
                y = obj.ymap(xout, hout, fout , it-1);
                
                pointselector = PlotPointSelector(session);
                curve = session.getCurrentCurve();
                if any(ismember(fields(DefaultValues.POINTNAMES), deblank(s.label)))
                   colorcfg =  obj.plotconfig.Sing;
                else
                    colorcfg = obj.plotconfig.UserSing;
                end
                
                
                line([[] x],[[] y], colorcfg{:} , 'Parent', obj.axeshandle , 'UserData' ,  [0 0 0 0 0 0] , 'ButtonDownFcn' ,@(o,e) pointselector.selectPointbyIndex(o , curve,s.index)     ); 
                d = axis(obj.axeshandle);
                skew = 0.01*[d(2)-d(1) d(4)-d(3)];
                text(x+skew(1), y+skew(2), s.label , 'Parent' , obj.axeshandle ,'UserData' ,  [0 0 0 0 0 0] , 'ButtonDownFcn' ,@(o,e) pointselector.selectPointByIndex(o , curve,s.index) , obj.plotconfig.label{:} ); 
            end

        end
        
    end
    
    methods(Static)
        function plotcurve(session, axeshandle, xmap , ymap , curve , pointselector , varargin)

            len = size(curve.x,2);
            x_ax = zeros(1,len);
            y_ax = x_ax;
            for i=1:len
               x_ax(i) = xmap(curve.x , curve.h , curve.f , i);
               y_ax(i) = ymap(curve.x , curve.h , curve.f , i);
            end

            colorconfig = session.sessiondata.getAllColorConfig(curve.getCurveType());
            axes(axeshandle);
            hold all
            plot(axeshandle, x_ax , y_ax , colorconfig.curve{:} ,  varargin{:});
            
            d = axis(axeshandle);
            skew = 0.01*[d(2)-d(1) d(4)-d(3)];
            
            for i = 2:(length(curve.s)-1)
                s_x = xmap(curve.x , curve.h , curve.f , curve.s(i).index );
                s_y = ymap(curve.x , curve.h , curve.f , curve.s(i).index );
                pointselectopts = {};
                
               if any(ismember(fields(DefaultValues.POINTNAMES), deblank(curve.s(i).label)))
                   colorcfg =  colorconfig.Sing;
                else
                    colorcfg = colorconfig.UserSing;
                end
                
                if (~isempty(pointselector)), pointselectopts = {'UserData' , [0 0 0 0 0 0] , 'ButtonDownFcn' ,@(o,e) pointselector.selectPoint(o , curve,i)}; end
                line([[] s_x],[[] s_y], colorcfg{:} , 'Parent', axeshandle ,  pointselectopts{:});
                text(s_x+skew(1), s_y+skew(2), label2tex(curve.s(i).label) , 'Parent' , axeshandle , colorconfig.label{:} , pointselectopts{:});
            end
            
        end

                
        function plotOrbit2(session, axeshandle , xmap , ymap, curve , pointselector , varargin)
               
                len = length(curve.x);
                colorconfig = session.sessiondata.getAllColorConfig(curve.getCurveType());
                p = OrbitPlot(Plot2D(axeshandle, colorconfig  , xmap , ymap));
                
                p.outputPoint(curve.x, [] , [], 1 , {} , SessionOutput.vector2str(curve.x(:,1)));
                for i=2:len
                        p.output([], curve.x, curve.s(i) , [] , [] , i);
                        p.outputPoint(curve.x, [] , [], i , {} , SessionOutput.vector2str(curve.x(:,i)));                     
                end
        
        end

                
        function plotIC(session, axeshandle , xmap , ymap, curve , pointselector , varargin)   
            tempx = xmap(curve.x , curve.h , curve.f , 1);
            tempy = ymap(curve.x , curve.h , curve.f , 1);
            assert(numel(tempx) == numel(tempy), 'both axis need to be coordinates for IC curve plot')
            if numel(tempx)>1
                len = size(curve.x,2);
                x_ax = zeros(size(curve.x,1)+1,len);
                y_ax = x_ax;
                for i = 1:len
                    x_ax(:,i) = xmap(curve.x , curve.h , curve.f , i);
                    y_ax(:,i) = ymap(curve.x , curve.h , curve.f , i);
                end
                xcoord = x_ax(end,end);
                ycoord = y_ax(end,end);

                PIC(curve, curve.x, xcoord, ycoord)
            else
                Plot2D.plotcurve(session, axeshandle, xmap, ymap, curve, pointselector, varargin{:})
            end
        end
        
        function plot(session, axeshandle, xmap , ymap , curve , pointselector , varargin)
           switch curve.getCurveType().getLabel()
               case 'O'
                   Plot2D.plotOrbit2(session, axeshandle, xmap , ymap , curve , pointselector , varargin{:});
               case 'IC'
                   Plot2D.plotIC(session, axeshandle, xmap , ymap , curve , pointselector , varargin{:});
               otherwise
                   Plot2D.plotcurve(session, axeshandle , xmap , ymap, curve , pointselector , varargin{:});
           end
      
        end 
        
    end
    
    
    
    
    
    
    
end
