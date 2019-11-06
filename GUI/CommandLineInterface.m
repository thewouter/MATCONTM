classdef CommandLineInterface
    %COMMANDLINEINTERFACE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        session
    end
    
    methods
        function obj = CommandLineInterface()
            global session;
            obj.session = session;
        end
        function setCoordinates(obj,varargin)
            startdata = obj.session.getStartData();
            coords = startdata.getCoordinates();
            if (length(coords) == length(varargin))
                vals = vertcat(varargin{:});
            else
                vals = varargin{1};
            end
            if (length(coords) ~= length(vals))
                error('coordinates length mismatch');
            end
            for i = 1:length(coords)
                startdata.setCoordinate( coords{i} , vals(i));
            end
            startdata.notify('settingChanged');
        end
        function setParameters(obj,varargin)
            startdata = obj.session.getStartData();
            params = startdata.getParameters();
            if (length(params) == length(varargin))
                vals = vertcat(varargin{:});
            else
                vals = varargin{1};
            end
            
            
            if (length(params) ~= length(vals))
                error('parameters length mismatch');
            end
            for i = 1:length(params)
                startdata.setParameter( params{i} , vals(i));
            end
            startdata.notify('settingChanged');
        end
        function setCo(obj,varargin)
            setCoordinates(obj,varargin{:});
        end
        function setPa(obj,varargin)
            setParameters(obj,varargin{:});
        end
        function setData(obj,varargin)
            obj.setCoordinates(varargin{1});
            obj.setParameters(varargin{2});
        end
        function setIP(obj,varargin)
            obj.setCoordinates(varargin{1});
            obj.setParameters(varargin{2});
        end        
        
        function p = getParameters(obj)
            p = obj.getPa();
        end
        function c = getCoordinates(obj)
            c = obj.getCo();
        end
        function  n = getDimension(obj)
            n = length(obj.getCo());
        end
        
        function p = getPa(obj)
            p = obj.session.getStartData().getParameterValues();
            p = p';
        end
        function c = getCo(obj)
            c = obj.session.getStartData().getCoordinateValues();
            c = c';
        end        
        function n = getIterationN(obj)
            n = obj.session.getStartData().getSetting('iterationN');
        end
        function data = getData(obj)
           data = struct('param', obj.getPa() , 'coord' , obj.getCo()); 
        end
        
        function data = getIP(obj)
           data = struct('param', obj.getPa() , 'coord' , obj.getCo()); 
        end        
        
        function [sysobj,handle] = getSystem(obj)
           if(obj.session.hasSystem())
               handle = obj.session.getSystem().getFunctionHandle();
               sysobj = MatcontMSystem(handle);
           else
               sysobj = [];
               handle = [];
           end
        end
        
        function it = getIternationN(obj)
            it = [];
            if (obj.session.hasSystem())
                it =  obj.session.starterdata.getSetting('iterationN');
            end
        end
        
        function actives = getActiveParams(obj)
            if (obj.session.hasSystem())
                actives = obj.session.starterdata.getActiveParams();
            else
               actives = []; 
            end
            
        end
        
        
        function setIterationN(obj, itn)
            if (obj.session.hasSystem())
                obj.session.starterdata.setSetting('iterationN', itn);
            end           
            
        end
        
        
        function [x,v,s,h,f] = getCurve(obj)
            curve = obj.session.getCurrentCurve();
            if (nargout == 5)
                x = curve.x; v = curve.v; s = curve.s; h = curve.h; f = curve.f;
            else
                x = struct();
                x.x = curve.x; x.v = curve.v; x.s = curve.s; x.h = curve.h; x.f = curve.f;
            end
        end
    end
end

