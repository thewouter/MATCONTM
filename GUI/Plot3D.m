classdef Plot3D
    %PLOT3D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        axeshandle
        xmap
        ymap
        zmap
        plotconfig
        plotops = {};
        
        group;
    end
    
    methods
        function obj = Plot3D(axeshandle, plotconfig, xmap , ymap, zmap)
            obj.axeshandle = axeshandle;
            obj.xmap = xmap;
            obj.ymap = ymap;
            obj.zmap = zmap;
            
            obj.plotconfig = plotconfig;
            obj.group = hggroup('Parent' , obj.axeshandle );
            
        end
        
        function [ph,th] =  outputPoint(obj,  xout, hout, fout , i , plotops, pointmsg)
            it = i(end);
            x = obj.xmap(xout, hout, fout, it);
            y = obj.ymap(xout, hout, fout, it);
            z = obj.zmap(xout, hout, fout, it);
            
            pointmsg = [num2str(i) ': ' pointmsg];
            
            ph = line([[] x],[[] y],[[] z], 'Parent' , obj.group ,  obj.plotconfig.orbitpoint{:} , 'ButtonDownFcn' , @(o,e) disp(pointmsg), plotops{:});
            
            if getSwitch('orbitdrawpointnumbers')
                
                d = axis(obj.axeshandle);
                skew = 0.01*[d(2)-d(1) d(4)-d(3) d(6)-d(5)];
                th = text(x+skew(1),y+skew(2),z+skew(3), num2str(i) , 'Parent' ,obj.axeshandle  , 'ButtonDownFcn' , @(o,e) disp(pointmsg), obj.plotconfig.label{:} , 'UserData' , [x y z]);
                
            else
                th = -1;
            end
        end
        
        function output(obj, session , xout, s , hout, fout , i)
            
            it = i(end);
            if i(end)>1, jj = 1;else jj = 0;end
            
            
            x0 = obj.xmap(xout, hout, fout , it-jj);
            x1 = obj.xmap(xout, hout, fout, it);
            y0 = obj.ymap(xout, hout, fout , it-jj);
            y1 = obj.ymap(xout, hout, fout, it);
            z0 = obj.zmap(xout, hout, fout , it-jj);
            z1 = obj.zmap(xout, hout, fout, it);
            
            line([x0 x1] , [y0 y1], [z0 z1] , 'Parent' , obj.group  , obj.plotconfig.curve{:} , obj.plotops{:});
            
            
            if ((it > 2) && ( s.index == (it - 1) ))
                x = obj.xmap(xout, hout, fout , it-1);
                y = obj.ymap(xout, hout, fout , it-1);
                z = obj.zmap(xout, hout, fout , it-1);
                
                pointselector = PlotPointSelector(session);
                curve = session.getCurrentCurve();
                if any(ismember(fields(DefaultValues.POINTNAMES), deblank(s.label)))
                    colorcfg =  obj.plotconfig.Sing;
                else
                    colorcfg = obj.plotconfig.UserSing;
                end
                

                line([[] x],[[] y],[[] z] , colorcfg{:} , 'Parent', obj.axeshandle  ,'UserData' ,  [0 0 0 0 0 0] , 'ButtonDownFcn' ,@(o,e) pointselector.selectPointByIndex(o , curve,s.index)  );

                d = axis(obj.axeshandle);
                skew = 0.01*[d(2)-d(1) d(4)-d(3) d(6)-d(5)];
                text(x+skew(1), y+skew(2),z+skew(3),  s.label ,  'Parent' , obj.axeshandle ,'UserData' ,  [0 0 0 0 0 0] , 'ButtonDownFcn' ,@(o,e) pointselector.selectPointByIndex(o , curve,s.index) , obj.plotconfig.label{:});
            end
            %     hold off
        end
        
    end
    methods(Static)
        function plotcurve(session, axeshandle, xmap , ymap , zmap, curve , pointselector , varargin)
            len = size(curve.x,2);
            x_ax = zeros(1,len);
            y_ax = x_ax;
            z_ax = x_ax;
            for i=1:len
                x_ax(i) = xmap(curve.x , curve.h , curve.f , i);
                y_ax(i) = ymap(curve.x , curve.h , curve.f , i);
                z_ax(i) = zmap(curve.x , curve.h , curve.f , i);
            end
            colorconfig = session.sessiondata.getAllColorConfig(curve.getCurveType());
          
            axes(axeshandle);
            hold all
            plot3(axeshandle, x_ax , y_ax , z_ax, colorconfig.curve{:}, varargin{:});
            
            d = axis(axeshandle);
            skew = 0.01*[d(2)-d(1) d(4)-d(3) d(6)-d(5)];
            for i = 2:(length(curve.s)-1)
                s_x = xmap(curve.x , curve.h , curve.f , curve.s(i).index );
                s_y = ymap(curve.x , curve.h , curve.f , curve.s(i).index );
                s_z = zmap(curve.x , curve.h , curve.f , curve.s(i).index );
                pointselectopts = {};
                
                if any(ismember(fields(DefaultValues.POINTNAMES), deblank(curve.s(i).label)))
                   colorcfg =  colorconfig.Sing;
                else
                    colorcfg = colorconfig.UserSing;
                end
                
                if (~isempty(pointselector)), pointselectopts = {'UserData' , [0 0 0 0 0 0] , 'ButtonDownFcn' ,@(o,e) pointselector.selectPoint(o , curve,i)}; end
                line([[] s_x],[[] s_y], [[] s_z], colorcfg{:}  , 'Parent', axeshandle, pointselectopts{:});
                text(s_x+skew(1), s_y+skew(2), s_z+skew(3), label2tex(curve.s(i).label) , 'Parent' , axeshandle,colorconfig.label{:} , pointselectopts{:});
            end
            
        end
        
        function plotOrbit2(session, axeshandle , xmap , ymap, zmap, curve , pointselector , varargin)
            
            len = length(curve.x);
            colorconfig = session.sessiondata.getAllColorConfig(curve.getCurveType());
            p = OrbitPlot(Plot3D(axeshandle,  colorconfig , xmap , ymap, zmap));
            
            p.outputPoint(curve.x, [] , [], 1 , {} , SessionOutput.vector2str(curve.x(:,1)));
            for i=2:len
                p.output([], curve.x, curve.s(i) , [] , [] , i);
                p.outputPoint(curve.x, [] , [], i , {} , SessionOutput.vector2str(curve.x(:,i)));
            end
            
        end
        
        function plot(session, axeshandle, xmap , ymap ,zmap, curve , pointselector , varargin)
            if (strcmp('O' , curve.getCurveType().getLabel()))
                Plot3D.plotOrbit2(session, axeshandle, xmap , ymap ,zmap, curve , pointselector , varargin{:});
            else
                Plot3D.plotcurve(session, axeshandle , xmap , ymap,zmap, curve , pointselector , varargin{:});
            end
        end
    end
end
