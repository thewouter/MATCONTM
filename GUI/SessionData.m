classdef SessionData < handle
    %SESSIONDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        filepath
        data
        VERSION = 2;
    end
    
    methods
        function obj = SessionData(filepath)
            obj.filepath = filepath;
            if (exist(filepath, 'file'))
                try
                    load(filepath);
                    if (exist('data','var'))
                        printc(mfilename,['loaded data from ' filepath]);
                        obj.data = data;
                    else
                        printc(mfilename,['filename exists, no data: ' filepath]);
                        obj.data = [];
                    end
                catch ME
                    printc(mfilename, ME.message);
                    obj.data = [];
                    
                end
                
            else
                obj.data = [];
                
            end
            
            obj.initSwitch();
        end
        
        function recordThisState(obj, session)
            obj.data.state = recordState(obj,session);
            
        end
        
        function state = recordState(obj, session)
            if(session.hasSystem())
                state = struct();
                state.system = session.getSystem().getName();
                state.diagram = session.getCurveManager().getDiagramName();
                
                c = session.getCurrentCurve();
                state.currentcurve = [];
                %!%! FIX: record state curvetype, curvepoint
                
                if (c.hasFile())
                    state.curvename = c.getLabel();
                else
                    state.curvename = [];
                end
                
                state.curve = c.saveobj();
                state.startdata = session.getStartData().saveobj();
                state.contdata  = session.getContData().saveobj();
                %              state.numdata = session.numericdata.saveobj();
                state.plotdata = session.plotmanager.saveobj();
                
                state.curvetype = session.getCurveType().getLabel();
                state.pointtype = session.getPointType().getLabel();
                
                state.branchselection = session.branchmanager.getSelectionIndex();
                
                state.version = obj.VERSION;
                
            else
                state = [];
            end
            
        end
        
        function restoreState(obj, session, optionalstate)
            %!%! FIX: restore state curvetype, curvepoint
            if (~obj.data.opt.restorestate.value) , return; end;
            
            if nargin == 3
                obj.data.state = optionalstate;
            end
            
            if (isfield(obj.data, 'state') && ~isempty(obj.data.state))
                if isfield(obj.data.state, 'version')
                   sdversion = obj.data.state.version; 
                else
                   sdversion = -1;
                end
                if sdversion ~= obj.VERSION
                   fprintf('ignored older state\n');
                   return; 
                end
                
                state = obj.data.state;
                try
                    sys = SystemSpace.loadSystem(session , state.system);
                catch ME
                    printc(mfilename, ME.message);
                    obj.data.state = [];
                    return;
                end
                % sys loaded
                dlist = InspectorDiagram.getDiagramList( sys.getPath());
                if (ismember(state.diagram , dlist))
                    dpath = [sys.getPath() '/' state.diagram];
                else
                    sys.setUp();
                    dpath = sys.getDefaultDiagramPath();
                end
                cm = CurveManager(session , dpath);
                
                if (isempty(state.curvename) || ~cm.curveExist(state.curvename))
                    curve = cm.getBlankCurve(obj);
                    curve.loadIn(state.curve);
                    curve.deFile();
                else
                    curve =  cm.loadCurveFromMemory( state.curvename , state.curve );
                end
                
                
                session.changeCurve(sys  ,  cm, curve, state.startdata , state.contdata);
                
                
                
                session.setCurveType(CurveType.getCurveTypeObject(state.curvetype));
                session.setPointType(StaticPointType.getPointTypeObject(state.pointtype));
                
                session.branchmanager.select(session ,  state.branchselection );
                
                %             session.numericdata.copyOver(state.numdata);
                session.plotmanager.loadIn(session, state.plotdata);
                
            end
        end
        
        
        
        function saveData(obj)
            data = obj.data;
            save(obj.filepath,'data');
        end
        
        
        function bool = getSwitch(obj , switchname)
            if isfield(obj.data.opt, switchname)
                bool = obj.data.opt.(switchname).value;
            else
                warning('getSwitched called with unknown switch');
                bool = 0;
            end
        end
        function setSwitch(obj, switchname , bool)
            obj.data.opt.(switchname).value = bool;
        end
        
        function initSwitch(obj)
            if (~isfield(obj.data, 'opt'))
                obj.data.opt.restorestate = struct('tag', 'debug' , 'value' , 1);
                obj.data.opt.popup = struct('tag', 'debug' , 'value' , 1);
                obj.data.opt.debug =  struct('tag', 'debug' , 'value' , 0);
                obj.data.opt.autoredraw =  struct('tag', 'debug' , 'value' , 0);
                obj.data.opt.autofit = struct('tag', 'debug' , 'value' , 0);
                obj.data.opt.orbitdrawpointnumbers = struct('tag', 'draw' , 'value' , 0);
                obj.data.opt.orbitdrawlines = struct('tag', 'draw' , 'value' , 0);
                
            end
            
        end
        function tag = getSwitchTag(obj, switchname)
            tag = obj.data.opt.(switchname).tag;
        end
        function name =  getSwitchName(obj, switchname)
            names = struct('orbitdrawpointnumbers', 'Draw numbers when plotting orbits', ...
                'orbitdrawlines' , 'Draw lines when plotting orbits');
            
            if isfield(names, switchname)
                name = names.(switchname);
            else
                name = switchname;
            end
            
        end
        
        function colorSetup(obj)
            if ~isfield(obj.data, 'colorcfg')
                obj.data.colorcfg = struct('curve', struct()  , ...
                    'label' , {DefaultValues.OTHERCOLORCFG.LABEL} , ...
                    'sing' , {DefaultValues.OTHERCOLORCFG.SING} , ...
                    'usersing' ,{DefaultValues.OTHERCOLORCFG.USERSING} , ...
                    'orbitpoint' , {DefaultValues.OTHERCOLORCFG.ORBITPOINT} ...
                    );
                
            end
            
            
        end
        
        function cfg = getColorCfg(obj, curvetag)
            obj.colorSetup();
            if isfield(obj.data.colorcfg.curve , curvetag)
                cfg = obj.data.colorcfg.curve.(curvetag);
            else
                if isfield(DefaultValues.CURVECOLORCFG , curvetag)
                    cfg = DefaultValues.CURVECOLORCFG.(curvetag);
                    
                else
                    cfg = {};
                end
                
                obj.data.colorcfg.curve.(curvetag) = cfg;
                
            end
            
        end
        
        
        function cfgstruct = getAllColorConfig(obj, curve)
            cfgstruct = struct();
            cfgstruct.curve = obj.getColorCfg(curve.getLabel());
            cfgstruct.label = obj.getColorCfgLabel();
            cfgstruct.Sing  = obj.getColorCfgSing();
            cfgstruct.UserSing = obj.getColorCfgUserSing();
            cfgstruct.orbitpoint = obj.getColorCfgOrbitpoint();
        end
        
        function cfg = getColorCfgLabel(obj)
            obj.colorSetup();
            cfg = obj.data.colorcfg.label;
        end
        
        function cfg = getColorCfgSing(obj)
            obj.colorSetup();
            cfg = obj.data.colorcfg.sing;
        end
        function cfg = getColorCfgUserSing(obj)
            obj.colorSetup();
            cfg = obj.data.colorcfg.usersing;
        end
        
        function cfg = setColorCfg(obj, curvetag , cfg)
            obj.colorSetup();
            obj.data.colorcfg.curve.(curvetag) = cfg;
            
        end
        
        function setColorCfgLabel(obj , cfg)
            obj.colorSetup();
            obj.data.colorcfg.label = cfg;
        end
        
        function  setColorCfgSing(obj , cfg)
            obj.colorSetup();
            obj.data.colorcfg.sing = cfg;
        end
        function setColorCfgUserSing(obj , cfg)
            obj.colorSetup();
            obj.data.colorcfg.usersing = cfg;
        end
        
        
        function setColorCfgOrbitpoint(obj , cfg)
            obj.colorSetup();
            obj.data.colorcfg.orbitpoint = cfg;
        end
        
        function cfg = getColorCfgOrbitpoint(obj)
            obj.colorSetup();
            cfg = obj.data.colorcfg.orbitpoint;
        end
        
        
        
        
    end
    
end

