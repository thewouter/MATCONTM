classdef ManifoldModel < handle

properties
    
    syshandle = 0;
    coordNames = {};
    paramNames = {};
    nIteration = 1;
    startPoint = [];
    paramVal  = [];
    
    man_ds = [];
    opt_manifold = struct( ...
            'function', []  ,...
                'nmax', []   ,...  
          'Niterations', [] ,...          
         'distanceInit', []  ,...          
            'deltaMin', []  , ...
            'deltaMax', []   ,...
              'deltak', []  ,...
                 'eps', [] ,...
              'NwtMax', []   ,...
                 'Arc', []  ,...
            'alphaMax', [] ,...
            'alphaMin', [] ,...
       'deltaAlphaMax', []  ,...
       'deltaAlphaMin', []  ,...
    'searchListLength', []  );  

     opt_manifold_type = struct( ...
            'deltaMin', InputRestrictions.POS_0 , ...
            'deltaMax', InputRestrictions.POS_0  ,...
              'deltak', InputRestrictions.POS_0 ,...
                'nmax', InputRestrictions.INT_ge0  ,...
                 'eps', InputRestrictions.POS_0,...
              'NwtMax', InputRestrictions.INT_ge0 ,...
         'Niterations',  InputRestrictions.INT_g0 ,...
            'function',  InputRestrictions.CAT,...
                 'Arc',  InputRestrictions.POS_0,...
            'alphaMax',  InputRestrictions.POS_0,...
            'alphaMin',  InputRestrictions.POS_0,...
       'deltaAlphaMax',  InputRestrictions.POS_0,...
       'deltaAlphaMin',  InputRestrictions.POS_0,...
        'distanceInit',  InputRestrictions.NUM ,... 
       'JacobianIncrement' , InputRestrictions.NUM,...
    'searchListLength', InputRestrictions.INT_ge0  );    

    opt_manifold_type_cat = struct();
    
    SELECT_FP = 1;
    SELECT_OPT = 2;
    COMPUTING = 3;
    currentstage
    
    manifoldname = '';
    manifoldcollection;
    
end

events
   settingChanged 
   stageChanged
end


methods
        function obj = ManifoldModel( session , manifoldcollection , varargin)
            sys = session.getSystem();
            obj.coordNames = sys.getCoordinateList();
            obj.paramNames = sys.getParameterList();
            obj.syshandle = sys.getFunctionHandle();
            
            startdata = session.getStartData();
            obj.paramVal = startdata.getParameterValues();
            obj.startPoint = startdata.getCoordinateValues();
            obj.nIteration = startdata.getSetting('iterationN');
            
            obj.opt_manifold_type_cat.function = { struct('val' , 'UManifold' , 'name' , 'Unstable Manifold') , struct('val' , 'SManifold' , 'name' , 'Stable Manifold' ) ...
                              , struct('val', ' ' , 'name' , '<select>' )};
                                               
            obj.currentstage = obj.SELECT_FP;
            
            
            
            obj.manifoldcollection = manifoldcollection;
            %
            global mm;
            mm = obj;
            
        end
        
        function doOptionStage(obj)
            obj.currentstage = obj.SELECT_OPT;
            
            SessionOutput.setupSimplePrintconsole();
            
            global opt; opt = contset; %HACK , must be there for it to work (hidden argument)
            %coordinates must be col vector, parameters must be row vector

	    global GUIcontman
	    GUIcontman.syshandle = obj.syshandle;
	    GUIcontman.startPoint = obj.startPoint(:);
	    GUIcontman.paramVal = obj.paramVal;
	    GUIcontman.nIter = obj.nIteration;
		
            obj.opt_manifold = init_FPm_1DMan( obj.syshandle , obj.startPoint(:) , obj.paramVal' , obj.nIteration);
            global man_ds;
            obj.man_ds = man_ds;
            GUIcontman.mands = man_ds;
%            global sOutput; disp(sOutput.msgs{:});
            
            %%Probleem: in optM (opt_manifold) is Niterations plots niet
            %%meer aanwezig, en dat is nodig voor contman.m,  ik haal het
            %%uit man_ds en plaats het terug in optM indien niet aanwezig.
            
            if (~isfield(obj.opt_manifold , 'Niterations'))
                obj.opt_manifold.Niterations = obj.man_ds.Niterations;
            end

            obj.notify('settingChanged');
            obj.notify('stageChanged');
        end
        function doFixedPointStage(obj)
           obj.currentstage = obj.SELECT_FP;
           obj.notify('stageChanged');
        end
        function b = isFixedPointStage(obj)
               b = obj.currentstage == obj.SELECT_FP;
        end
        function b = isOptionStage(obj)
                b = obj.currentstage == obj.SELECT_OPT;
        end
            
        
        function val = getParamVal(obj , index)
            val = obj.paramVal(index);
        end
        function val = getCoordVal(obj , index)
            val = obj.startPoint(index);
        end        
         function val = getParamName(obj , index)
            val = obj.paramNames(index);
        end
        function val = getCoordName(obj , index)
            val = obj.coordNames(index);
        end
        function nr = getNrCoords(obj)
            nr = length(obj.coordNames);
        end
        function nr = getNrParams(obj)
            nr = length(obj.paramNames);
        end
        function names = getCoordNames(obj)
           names = obj.coordNames; 
        end
        function names = getParamNames(obj)
            names = obj.paramNames;
        end
        function val = getOpt(obj, optname)
            val = obj.opt_manifold.(optname);
        end

        function [type,values] = getOptType(obj , optname)
            type = obj.opt_manifold_type.(optname);
            
            if (type == InputRestrictions.CAT)
                values = obj.opt_manifold_type_cat.(optname);
            else
                values = {};
            end  
        end
        function list =  getOptNames(obj)
            list = fieldnames(obj.opt_manifold);
        end
        
        function setOpt(obj , optname , optval)
            obj.opt_manifold.(optname) = optval;
            obj.notify('settingChanged');
        end
        
        function setParamByIndex(obj , index , val)
            obj.paramVal(index) = val;
            obj.notify('settingChanged');
        end
            
        function setCoordByIndex(obj , index , val)
            obj.startPoint(index) = val;
            obj.notify('settingChanged');
        end
        function setCoord(obj , val)
           obj.startPoint = val;
           obj.notify('settingChanged');
        end
        function setParam(obj, val)
           obj.paramVal = val;
           obj.notify('settingChanged');
        end
        
        function [selectionMade, isStable ] = getManifoldTypeSelection(obj)
           selectionMade =  ~isempty(obj.opt_manifold.function) && ~isempty(strtrim(obj.opt_manifold.function ));
           isStable = strcmp(obj.opt_manifold.function , 'SManifold');
            
        end
        
        function v = getCoord(obj)
            v = obj.startPoint;
        end
        function v = getParam(obj)
            v = obj.paramVal;
        end
        function s = getManifoldName(obj)
           s = strtrim(obj.manifoldname); 
        end
        function setManifoldName(obj , name)
           obj.manifoldname = name;
           obj.notify('settingChanged');
        end
        function  b =hasManifoldName(obj)
            b = ~isempty(strtrim(obj.manifoldname));
        end
        
        function optM = getOptionsManifold(obj)
            optM = obj.opt_manifold;
        end
        function mands = getManDS(obj)
            mands = obj.man_ds;
        end
        function n = getIterationN(obj)
           n = obj.nIteration; 
        end
        function setIterationN(obj , n)
           obj.nIteration = n;
           obj.notify('settingChanged');
        end
        
        function lock(obj)
           obj.currentstage = obj.COMPUTING;
           obj.notify('stageChanged');
        end
        function unlock(obj)
           obj.currentstage = obj.SELECT_OPT;
           obj.notify('stageChanged');            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function doContMan(obj)
            obj.lock();
            global session; %HACK , fix later
            global man_ds;
            man_ds = obj.man_ds;
            global sOutput;
            sOutput = SessionOutput(session);
            MonitorPanel(session);
            sOutput.setStatus('Computing Manifold...');
            drawnow;


            [a,l] = contman(obj.opt_manifold);

            
            manname = obj.getManifoldName();
            if (obj.manifoldcollection.isNameTaken(manname))
                printconsole(['Name rejected: A manifold named "' manname  '" already exists']);
                obj.setManifoldName('');
                manname = '';
            end
            manifold = Manifold( a , l , obj.opt_manifold , man_ds);
            name = obj.manifoldcollection.addManifold(manifold , manname);
            
            printconsole(['Manifold stored under name: '  name ]);
            sOutput.endRun();
            
            
            obj.unlock();
        end
end


end
 
