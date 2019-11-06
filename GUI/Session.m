classdef Session < handle

    
    properties
    systemspath
	system;
        
        currentcurve;

        currentCurveType = CurveType_FP();
        currentPointType = PointType('FP');


        continuedata
        starterdata
        optioninterface
       
        windowmanager;
        curvemanager;
        branchmanager;
        plotmanager;
        
        unlocked = 1;

        sessiondata;
        configmanager;

    	numericData;
        DEBUG = false;
    end
    
    events
       stateChanged       
       pointChanged
       curveChanged  
       newSystem
    end
    
    
    methods
        %
        function obj = Session(systemspath)
            if (nargin == 1)
               obj.systemspath = systemspath; 
            else
               obj.systemspath = '../Systems/';
            end
            
            
            obj.system = [];
            obj.currentcurve = [];
            obj.curvemanager = [];

            obj.continuedata = ContDataModel();
            obj.starterdata = StartDataModel(obj);
            obj.optioninterface = ContinuerOptionInterface( obj.continuedata ,  obj.starterdata );
            
            obj.branchmanager = BranchManager(obj);
            obj.plotmanager = PlotManager(obj);
            
            
            obj.sessiondata =  SessionData([obj.systemspath  '/Session.mat']);
            obj.sessiondata.restoreState(obj);
            obj.configmanager = ConfigManager(obj.sessiondata);
            obj.windowmanager = WindowManager(obj , obj.sessiondata);
        end

	function launchNumeric(obj , fhandle)
        set(fhandle , 'CloseRequestFcn'  , @(o,e) numericclose(obj));
		obj.numericData = Numeric(obj , fhandle , true);
		%
	end
	function num =  getNumeric(obj)
		num = obj.numericData;
	end

        function reSet(obj)
            
            obj.system = [];
            obj.currentcurve = [];
            obj.curvemanager = [];            
            obj.notify('pointChanged');
            obj.notify('curveChanged');
            obj.notify('newSystem');
            obj.notify('stateChanged');
            
        end
        
        %%
        function setCurveType(obj , curvedescr)
            ct = obj.getCurveType();
            if ~strcmp(curvedescr.getLabel() , ct.getLabel())
                obj.currentCurveType = curvedescr;
                obj.warnObservers('curveChanged');
            end
        end
        
        function ct =  getCurveType(obj)
            ct = obj.currentCurveType;
        end
        
        function setPointType(obj, pointdescr)
            pt = obj.getPointType();
            
            if ~strcmp(pointdescr.getLabel() , pt.getLabel())
                obj.currentPointType = pointdescr;
                obj.branchmanager.setup(obj);
                obj.notify('stateChanged');
            end
        end
        function pt = getPointType(obj)
           pt = obj.currentPointType; 
        end        
        
        %%

        function sys = getSystem(obj)
		if(~isempty(obj.system))
		    sys = obj.system;
		else
		    sys = System('EMPTY'); %FIXME memory leak
		end
        end
        
        function b = hasSystem(obj)
            b = ~isempty(obj.system);
        end


        
        
        function changeSystem(obj,system)
            if (isempty(obj.system) || ~system.cmp(obj.system))
               
               if (~isempty(obj.system))
                   obj.system.saveState(obj.sessiondata.recordState(obj));
               end
               obj.system = system;
               
               obj.warnObservers('newSystem');
            end
        end        
        
        function changeCurveManager(obj,system,curvemanager)
            obj.changeSystem(system);
            if(isempty(obj.curvemanager) || ~obj.curvemanager.cmp(curvemanager))
               obj.curvemanager = curvemanager;
               %obj.warnObservers('xChanged');
            end
            
        end
        function loadNewCurve(obj , system, curvemanager)
            
            obj.changeCurveManager(system,curvemanager);
            obj.currentcurve = curvemanager.getBlankCurve();
            
            %{
            state = system.getState();
            if (~isempty(state))
                obj.sessiondata.restoreState(obj, state); %needed ?
            end
            %}
            obj.syncWithCurve();
            obj.branchmanager.setup(obj); %point changed
            obj.warnObservers('curveChanged');
        end
        
	function syncWithCurve(obj)
		obj.setCurveType(obj.currentcurve.getCurveType());
                obj.setPointType(obj.currentcurve.getPointType());
        end

        function changeCurve(obj,system,curvemanager,curve , startdata, contdata)
            obj.changeCurveManager(system, curvemanager);
            
            obj.currentcurve = curve;
	    obj.syncWithCurve();
            
            obj.branchmanager.setup(obj); %point changed 
            
            obj.warnObservers('curveChanged'); %FIXME risque
           
            if (~isempty(contdata)),  obj.continuedata.copyOver(contdata); end 
            if (~isempty(startdata)), obj.starterdata.copyOver(startdata); end 
            
            
            
        end
        
        function loadInPoint(obj, system , curvemanager, parentcurve , selectedpoint , pointdata , startdata, contdata)
            parameters = pointdata.parameters;
            coordinates = pointdata.coordinates;
            
            for i = 1:length(parameters(:,1))
                startdata.setParameter( parameters{i,1} , parameters{i,2} );
            end
            dim = length(coordinates(:,1));
            for i = 1:dim
                startdata.setCoordinate( coordinates{i,1} , coordinates{i,2} );
            end
            
            
            curve = curvemanager.getBlankCurve(selectedpoint);
            curve.globals = parentcurve.globals;
            curve.depth = parentcurve.depth+1;
            curve.setParentCT( parentcurve.getCurveType().getLabel());
            
            obj.changeCurve(system,curvemanager, curve , startdata, contdata);
            
            ptype = deblank(selectedpoint.label);
            pt = StaticPointType.getPointTypeObject(ptype);
            
            if (ismember(parentcurve.getCurveType().getLabel(), {'HO' , 'HE'}))
                
                C = parentcurve.x(:,selectedpoint.index)';
                
                riclen = parentcurve.getRiccatiLength();
                C = C(:,1:(end - riclen - 1));
                C = reshape(C , dim , length(C) / dim);
                obj.starterdata.manifolddata.stable = [];
                obj.starterdata.manifolddata.unstable = [];
                obj.starterdata.manifolddata.conorbit = ConnectingOrbitCustom(C, [deblank(selectedpoint.label) '-points']);
                obj.starterdata.manifolddata.conorbitcol.addOrbit(obj.starterdata.manifolddata.conorbit);
            end
            
            if ~isempty(pt)
                obj.setPointType( pt );
                obj.branchmanager.setup(obj);
            end
        end
        
        
        function warnObservers(obj , state)
            notify(obj , state);
            if ~strcmp(state , 'stateChanged')
                notify(obj,'stateChanged');
            end
        end
        
        function sd = getStartData(obj)
           sd = obj.starterdata; 
        end
        function contdata = getContData(obj)
           contdata = obj.continuedata;
        end
        
        function wm = getWindowManager(obj)
           wm = obj.windowmanager; 
        end
        function bm = getBranchManager(obj)
            bm = obj.branchmanager;
        end
	function cm = getCurveManager(obj)
		cm = obj.curvemanager;
	end
    
    function c = getCurrentCurve(obj)
        if (isempty(obj.currentcurve))
            c = Curve();  
        else
            c = obj.currentcurve;
        end
    end
    
    function unloadCurrentCurve(obj)
        obj.loadNewCurve(obj.system , obj.curvemanager);
    end
    function reloadCurveManager(obj)
         loadNewCurve(obj , obj.system, CurveManager(obj , obj.system.getDefaultDiagramPath()) )
    end
    
        %%
        function val = isUnlocked(obj)
           val = obj.unlocked; 
        end
        
        function lock(obj)
            obj.unlocked = 0;
            obj.notify('stateChanged');
        end
        
        function unlock(obj)
            obj.unlocked = 1;
            obj.notify('stateChanged');
        end
        %%
        function bool = continuerAllowed(obj)
            bool = obj.curveSelected();
        end
        function bool = numericAllowed(obj)
            bool = obj.curveSelected();
        end
        
        function bool = plotAllowed(obj)
            bool = obj.curveSelected();
        end
        function bool = starterAllowed(obj)
            bool = obj.curveSelected() && ~strcmp(obj.getCurveType().getLabel(),'X');
        end

    
        function  b = isConfigured(obj)
            b = ~(strcmp( obj.getPointType.getLabel() , 'X') || strcmp(obj.getCurveType().getLabel() , 'X'));
        end  
    
        function bool = performContinueAllowed(obj)
            bool = obj.unlocked && obj.curveSelected() && obj.isConfigured() && obj.branchmanager.validSelectionMade();
        end     
        function bool = performExtendAllowed(obj)
            bool = obj.unlocked && obj.curveSelected() && obj.isConfigured() && ~obj.currentcurve.isEmpty() && obj.currentcurve.hasFile();
        end
        function bool = curveSelected(obj)
           bool =   ~isempty(obj.system) && ~isempty(obj.curvemanager) &&  ~isempty(obj.currentcurve);
        end
        
        function bool = allowCurveSelect(obj)
           bool = ~isempty(obj.system); 
        end
        function bool = allowPointSelect(obj)
           bool = obj.curveSelected() && ~obj.currentcurve.isEmpty(); 
        end        
        
        %%
        function path = getSystemsPath(obj)
           path = obj.systemspath; 
        end
        
        function pm = getPlotManager(obj)
           pm = obj.plotmanager; 
        end
        
        %%
        function shutdown(obj)
           printc(mfilename , 'start shutdown');
           obj.sessiondata.recordThisState(obj);
           obj.plotmanager.destructor();
           
           obj.sessiondata.saveData();
           if (~isempty(obj.system))
              obj.system.saveState(obj.sessiondata.data.state);
           end
           
           printc(mfilename , 'end shutdown');
            
        end
       
        function bool = getSwitch(obj , switchlabel)
           bool = obj.sessiondata.getSwitch(switchlabel); 
        end
        
        function updateNumeric(obj) 
            
            if (~isempty(obj.numericData))
               obj.numericData.changed(obj); 
            end
        end
        
       
    end
    
end



function numericclose(session)
    if (session.isUnlocked())
        session.windowmanager.closeWindow('numeric');
        session.numericData = [];
    end
end
