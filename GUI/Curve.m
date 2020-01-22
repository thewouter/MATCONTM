classdef Curve < handle
    %CURVE Summary of this class goes here
    %   Detailed explanation goes here
    
    
    
    properties
        x = []
        v = []
        s = []
        h = []
        f = []
        
        startpoint = [];
        
        globals = struct();

        curvetype = ''
        pointtype = ''
	multiplyIterationN = 1;
        label = '_'
        path = ''
        depth = 0;        
        parentcurvetag = '';        
        plotopts = []
        initUsed = [];

	startpoints = [];
    end
    
    
    
    
    
    methods
        function obj = Curve( x,v,s,h,f,globals)
            obj.curvetype = CurveType_FP();   %default
            obj.pointtype = PointType('FP');  %default
            
            if (nargin == 0)
                return
            elseif(nargin == 1)
                filename = x;
                load(filename);
                %TODO: check of alle vars erin zitten  FIXME
                obj.setData(x,v,s,h,f); %from file

                if(exist('multiplyIterationN' , 'var'))
                    obj.multiplyIterationN = multiplyIterationN;
                end
                if(exist('initUsed' , 'var'))
                    obj.initUsed = initUsed;
                end	
                if(exist('initialpointdata' , 'var'))
                    obj.startpoint = initialpointdata;
                end	       
                pointtypelbl = deblank(point);
                curvetypelbl = deblank(ctype);
                obj.curvetype = CurveType.getCurveTypeObject(curvetypelbl);
                obj.pointtype = StaticPointType.getPointTypeObject(pointtypelbl);
                
                obj.path = filename;
                
                %load in curvetype dependant global vars
                list = obj.curvetype.getDependantGlobalVars();
                for i = 1:length(list)
                    if (exist(list{i} , 'var'))
                        eval(['obj.globals.'  list{i}  '  =  ' list{i}  ' ;']);
                    else
                        warning(['expected ' list{i} ' to be in ' filename]);
                    end
                end
                
            elseif(nargin == 6)
                obj.setData(x,v,s,h,f);
                obj.globals = globals;
            end
            
        end
        function save(obj,filename)
            x = obj.x;
            v = obj.v;
            s = obj.s;
            h = obj.h;
            f = obj.f;
	    multiplyIterationN = obj.multiplyIterationN;
        initUsed = obj.initUsed;
        initialpointdata = obj.startpoint;
            point = obj.pointtype.getLabel();
            ctype = obj.curvetype.getLabel();
            
            fields = fieldnames(obj.globals);
            for i = 1:length(fields)
               eval([ fields{i} '  =  obj.globals.' fields{i} '  ;']);  
            end
            
            save(filename , 'x','v','s','h','f','point','ctype' , 'multiplyIterationN', 'initialpointdata' , 'initUsed' , fields{:});
        end

        function iu = getInitLabel(obj)
           iu = obj.initUsed; 
        end
        
        
        function ct = getCurveType(obj)
            ct = obj.curvetype;
        end
        function pt = getPointType(obj)
            pt = obj.pointtype; 
        end
        function setPointType(obj, pt)
           obj.pointtype = pt; 
        end
        function setCurveType(obj, ct)
            obj.curvetype = ct;
        end
        
        
        function b = isEmpty(obj)
            b = isempty(obj.x);
        end
        
        
        function  setData(obj,x,v,s,h,f)
            obj.x = x;
            obj.v = v;
            obj.s = s;
            obj.h = h;
            obj.f = f;        
        
        end
        function setInitData(obj, initUsed , inm)
            obj.multiplyIterationN = inm;
            obj.initUsed = initUsed;
	end	
        function loadGlobalVars(obj,curvetype)
            list = curvetype.getDependantGlobalVars();
            
            for i = 1:length(list)
                if (isfield(obj.globals , list{i}))
                    eval(['global ' list{i} ' ; ' list{i} '  =  obj.globals.' list{i}  ' ;']);
                end
            end
        end
        
        
        function saveGlobalVars(obj,curvetype)
            list = curvetype.getDependantGlobalVars();
            for i = 1:length(list)
                eval(['global ' list{i} ' ;  obj.globals.'  list{i}  '  =  ' list{i}  ' ;']);
            end
        
        end
        function l  = getLabel(obj)
            l = obj.label;
        end

        function b = hasFile(obj)
           b = ~isempty(obj.path); 
        end
        
        function p = extractP0(obj)
            gls = obj.curvetype.getDependantGlobalVars();
	    p = [];
            for i = 1:length(gls)
               if (~strcmp(gls{i} , 'cds'))
                   try
                   p = eval(['obj.globals.'  gls{i} '.P0']);
                   catch
                   end
                   return;
               end
            end
            p = [];
        end
        
        function n = extractIterationN(obj)
            gls = obj.curvetype.getDependantGlobalVars();
            n = -101114114;
            for i = 1:length(gls)
                if (~strcmp(gls{i} , 'cds'))
                    try
                        n = eval(['obj.globals.'  gls{i} '.Niterations']);
                    catch
                        try
                            n = eval(['obj.globals.'  gls{i} '.niteration']);
                        catch
                            try 
                                n = eval(['obj.globals.'  gls{i} '.Niteration']);
                            catch
                            end
                        end
                    end
                    return;
                end
            end
            n = Inf;
        end
        


        function b = isSeeded(obj)
           b = ~isempty(obj.startpoint);
        end
        
        function b = cmp(obj, curve)
           if (isempty(curve))
              b = false;
           else
              b = strcmp(obj.path , curve.path);
           end
        end
        function A = saveobj(obj)       
            A.x = obj.x;
            A.v = obj.v;
            A.s = obj.s;
            A.h = obj.h;
            A.f = obj.f;
            A.multiplyIterationN = obj.multiplyIterationN;
            A.initUsed = obj.initUsed;
            A.startpoint = obj.startpoint;
            A.globals = obj.globals;
            A.label = obj.label;
            A.path = obj.path;
            A.depth = obj.depth;
            
            A.pointtype = obj.pointtype.getLabel();
            A.curvetype = obj.curvetype.getLabel();
            
        end
        
        
        function loadIn(obj, A)
            obj.x = A.x;
            obj.v = A.v;
            obj.s = A.s;
            obj.h = A.h;
            obj.f = A.f;
            obj.multiplyIterationN = A.multiplyIterationN;
            obj.initUsed = A.initUsed;
            obj.startpoint = A.startpoint;
            obj.globals = A.globals;
            obj.label = A.label;
            obj.path = A.path;
            obj.depth = A.depth;        
         
            
            obj.curvetype = CurveType.getCurveTypeObject(A.curvetype);
            obj.pointtype = StaticPointType.getPointTypeObject(A.pointtype);
        end

	function copyOverAttributes(obj , c)
            obj.startpoint = c.startpoint;
            obj.globals = c.globals;
            obj.depth = c.depth;        
            obj.curvetype =  c.curvetype;
            obj.pointtype = c.pointtype;
    end
    %{
    function b = doesStillExist(obj, session)
       b  = exist(obj.path, 'file') && any(strfind(obj.path,  session.getSystemsPath()  ));
    end
    %}
    function  ct = getParentCT(obj)
        ct = obj.parentcurvetag;
    end
    function setParentCT(obj, tag)
       obj.parentcurvetag = tag; 
    end
    function deFile(obj)
       obj.path = ''; 
       obj.label = '[]';
    end
    
    function startdata = getStartData(obj , system)
            printc(mfilename, 'getStartData CALL');
            if (~ obj.hasFile())
               warning(['unexpected call getStartData ' mfilename]);
            end
            
            startdata = StartDataModel(system ,obj.curvetype);
            
            for i = obj.globals.cds.options.ActiveParams
                startdata.setFreeParameterByIndex(i , true);
            end
            
            for i = obj.globals.cds.options.IgnoreSingularity
                startdata.setMonitorSingularitiesByIndex(i,false);
            end
            
            if (~isempty(obj.globals.cds.options.Increment)) , startdata.setJacobian('increment' , obj.globals.cds.options.Increment); end
            if (~isempty(obj.globals.cds.options.Multipliers)) , startdata.setMultipliers(obj.globals.cds.options.Multipliers); end

            iterationN = obj.extractIterationN();
            
	    startdata.setSetting('iterationN' , iterationN);
             
             
            if (~isempty(obj.globals.cds.options.AutDerivativeIte)) , startdata.setSetting('ADnumber', obj.globals.cds.options.AutDerivativeIte); end
            
            P0 = obj.extractP0();
            for i = 1:length(P0)
               startdata.setParameterByIndex(i , P0(i)); 
            end
            
            coordlist = system.getCoordinateList();
            for i = 1:length(coordlist)
               startdata.setCoordinate( coordlist{i} , obj.x(i,1) ); 
            end
            if (isfield(obj.globals.cds.options,'Userfunctions') && isfield(obj.globals.cds.options,'UserfunctionsInfo'))
                startdata.configUserFunctions(   SystemSpace.getEnabledUserFunctions( obj.globals.cds.options.Userfunctions , obj.globals.cds.options.UserfunctionsInfo));
            end
           
        end   
    
    
        function  [points , dimension] = getNrPoints(obj)
            if (isempty(obj.x))
               points = 0;
               dimension = [];
               
            else
                if (ismember(obj.getCurveType().getLabel() , {'HO' , 'HE' , 'HomT' , 'HetT' }))
                    if(isfield(obj.globals, 'homds'))
                        ds = obj.globals.homds;
                    elseif (isfield(obj.globals,'hetds'))
                        ds = obj.globals.hetds;
                        
                    else
                       warning('else happended'); 
                    end
                    
                    points = obj.f(1);
                    dimension = ds.nphase;
                else
                     points = 1;
                     dimension = []; %%HACK
                end
            end
            
        end
        
        function  len = getRiccatiLength(obj)
            if (isempty(obj.x))
                len = 0;
            else
                if (ismember(obj.getCurveType().getLabel() , {'HO' , 'HE' , 'HomT' , 'HetT' }))
                    if(isfield(obj.globals, 'homds'))
                        ds = obj.globals.homds;
                    elseif (isfield(obj.globals,'hetds'))
                        ds = obj.globals.hetds;
                        
                    else
                        warning('else happended');
                    end
                    
                    len = ds.riccativectorlength;
                else
                    len = 0;
                end
            end
            
        end
        
        
    end
    methods(Static)
        
        
        
        function installCurve(session,sys, curvemanager, curvename)
            curve = curvemanager.getCurveByName(curvename);
            
            P0 = curve.extractP0();
            if (isempty(P0))
                P0 = NaN * ones(1, length( session.getSystem().getParameterList() ));
            end
         
	    iternum_of_startpoint = curve.extractIterationN() / curve.multiplyIterationN;
   
            [startdata, contdata] = ContinuerOptionInterface.reconstructData( sys , curve.getCurveType(), ...
                curve.globals.cds , P0 , iternum_of_startpoint , curve.x(:,1));
            
            session.changeCurve(sys  ,  curvemanager , curve, startdata , contdata);
            
        end
        
        function data = getPointData(startdata , curve , P0, pointindex)
            coords = startdata.getCoordinates();
            params = startdata.getParameters();
            
            X = curve.x(: , curve.s(pointindex).index );
            
            data.coordinates = cell(length(coords) , 2);
            data.parameters = cell(length(params) , 2);
            
            for i = 1:length(coords)
                data.coordinates{i,1} = coords{i};
                data.coordinates{i,2} = X(i);
            end
            
            x_index = length(coords);
            
            for i = 1:length(params)
                data.parameters{i , 1} = params{i};
                
                if (startdata.getFreeParameter(params{i}))
                    x_index = x_index + 1;
                    data.parameters{i , 2} = X(x_index);
                else
                    data.parameters{i , 2} = P0(i);
                end
            end
            
        end

        
        function loadInPoint(session , system , curvemanager , curve , pointindex)
            
            selectedpoint = curve.s(pointindex);
            P0 = curve.extractP0();
            
            [startdata,contdata]  = ContinuerOptionInterface.reconstructData(system , curve.getCurveType(), ...
                curve.globals.cds , P0 , curve.extractIterationN() , curve.x(:,1));
            
            pointdata = Curve.getPointData(startdata , curve , P0, pointindex);
            
            session.loadInPoint(system , curvemanager, curve, selectedpoint , pointdata , startdata, contdata);

        end
        
    end
end

