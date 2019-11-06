classdef StartDataModel < handle
    % Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        parameters
        freeparameters
        branchparameters
        coordinates
        jacobiandata
        settings
        singularities
        showmultipliers
        
        userfunctions;
        
        enabled %boolstruct
        
        eventlistener
        
        frozen = 0;
        currentcurvetype;
        
        orbitpoints;
        manifolddata = [];
    end
    
    events
        settingChanged
        structureChanged
        freeParamChanged
    end
    
    methods
        function obj = StartDataModel(varargin)
            
            
            
            obj.setDefaults();
            
            %%%%%%%
            
            if (nargin == 1)
                session = varargin{1};
                obj.eventlistener = session.addlistener('newSystem', @(o,e) obj.systemChanged(session));
                obj.eventlistener = session.addlistener('curveChanged', @(o,e) obj.curveChanged(session));
                system = session.getSystem();
                
                curvetype = session.getCurveType();
            else
                system = varargin{1};
                curvetype = varargin{2};
                obj.frozen = 1;
            end
            
            obj.configureData(system,curvetype)
        end
        
        function setDefaults(obj)
            obj.manifolddata.stable = [];
            obj.manifolddata.unstable = [];
            obj.manifolddata.conorbitcol = ConnectingOrbitCollection({});
            obj.manifolddata.conorbit = [];
            
            % Default settings:
            obj.settings.iterationN = DefaultValues.STARTDATA.iterationN;
            obj.settings.ADnumber = DefaultValues.STARTDATA.ADnumber;
            obj.settings.amplitude = DefaultValues.STARTDATA.amplitude;
            obj.settings.orbitpoints = DefaultValues.STARTDATA.orbitpoints;
            obj.enabled.FieldsModel = 0;
            obj.jacobiandata.increment = DefaultValues.STARTDATA.increment;
            obj.showmultipliers = DefaultValues.STARTDATA.showmultipliers;
            
            
        end
        
        
        function copyOver(obj ,startdata)
            obj.parameters = startdata.parameters;
            obj.freeparameters = startdata.freeparameters;
            obj.branchparameters = startdata.branchparameters;
            obj.coordinates = startdata.coordinates;
            obj.jacobiandata = startdata.jacobiandata;
            obj.settings = startdata.settings;
            obj.singularities = startdata.singularities;
            obj.showmultipliers = startdata.showmultipliers;
            obj.enabled = startdata.enabled;
            
            if (isfield(startdata,'uflist'))
                obj.configUserFunctions(startdata.uflist);
            else
                obj.userfunctions = startdata.userfunctions;
            end
            
            
            if (~isempty(startdata.manifolddata))
                if (~isempty(startdata.manifolddata.stable))
                    obj.manifolddata.stable = Manifold.loadFromStruct(startdata.manifolddata.stable);
                end
                if (~isempty(startdata.manifolddata.unstable))
                    obj.manifolddata.unstable = Manifold.loadFromStruct(startdata.manifolddata.unstable);
                end
                if (~isempty(startdata.manifolddata.conorbit))
                    obj.manifolddata.conorbit = ConnectingOrbit.genericLoadFromStruct(startdata.manifolddata.conorbit);
                    obj.manifolddata.conorbitcol.addOrbit(obj.manifolddata.conorbit);
                end
            end
            
            obj.enabled.FieldsModel = 0; %DO CHANGE: when 'Point' is a remembered state.
            
            obj.notify('structureChanged');
        end
        
        function A = saveobj(obj)
            A.parameters = obj.parameters;
            A.freeparameters = obj.freeparameters;
            A.branchparameters = obj.branchparameters;
            A.coordinates = obj.coordinates;
            A.jacobiandata = obj.jacobiandata;
            A.settings = obj.settings;
            A.singularities = obj.singularities;
            A.showmultipliers = obj.showmultipliers;
            A.enabled = obj.enabled;
            
            A.uflist = SystemSpace.getEnabledUserFunctions( obj.hasValidUserfunctions() , obj.userfunctions);
            
            A.manifolddata = struct('stable' , [] , 'unstable' , [] , 'conorbit' , []);
            if (~isempty(obj.manifolddata))
                if (~isempty(obj.manifolddata.stable))
                    A.manifolddata.stable =  obj.manifolddata.stable.saveobj();
                end
                if (~isempty(obj.manifolddata.unstable))
                    A.manifolddata.unstable =  obj.manifolddata.unstable.saveobj();
                end
                if (~isempty(obj.manifolddata.conorbit))
                    A.manifolddata.conorbit = obj.manifolddata.conorbit.saveobj();
                end
            end
        end
        
        function curveChanged(obj,session)
            obj.currentcurvetype = session.getCurveType();
            allowedlist = obj.currentcurvetype.allowedStarterOptions();
            
            obj.enabled = struct();
            for i = 1:length(allowedlist)
                obj.enabled.(allowedlist{i}) = true;
            end
            
            obj.configureSingTests(session.getSystem() , obj.currentcurvetype);
            
            session.updateNumeric();
            obj.notify('structureChanged');
        end
        
        function systemChanged(obj,session)
            system = session.getSystem();
            obj.setDefaults();
            
            obj.parameters = struct();
            obj.freeparameters = struct();
            obj.branchparameters = struct();
            obj.coordinates = struct();
            
            list = system.getParameterList();
            for i = 1:length(list)
                obj.parameters.(list{i}) = 0;
                obj.freeparameters.(list{i}) = 0;
                obj.branchparameters.(list{i}) = 0;
            end
            
            list = system.getCoordinateList();
            for i = 1:length(list)
                obj.coordinates.(list{i}) = 0;
            end
            obj.configureSingTests(session.getSystem() , session.getCurveType());
            obj.userfunctions = system.getUserfunctions();
            
            session.updateNumeric();
            obj.notify('structureChanged');
        end
        function configureSingTests(obj,system,curvetype)
            [singlist , minimumdim] = curvetype.getTestfunctions();
            dim = system.getNrCoordinates();
            
            obj.enabled.singularities = struct();
            %obj.singularities = struct();
            
            
            for i = 1:length(singlist)
                obj.enabled.singularities.(singlist{i}) = ( dim >= minimumdim(i) );
                if (isfield(obj.singularities, singlist{i}))
                    %if (dim < minimumdim(i))
                    obj.singularities.(singlist{i}) = ( dim >= minimumdim(i) );
                    %end
                    
                else
                    obj.singularities.(singlist{i}) =  ( dim >= minimumdim(i) );
                    %disp(obj.singularities.(singlist{i}));
                end
                
            end
            %obj.singularities
            
        end
        
        
        function configureData(obj,system,curvetype)
            
            obj.currentcurvetype = curvetype;
            obj.enabled = struct();
            obj.enabled.singularities = struct();
            obj.parameters = struct();
            obj.coordinates = struct();
            obj.singularities = struct();
            obj.freeparameters = struct();
            obj.branchparameters = struct();
            
            
            allowedlist = curvetype.allowedStarterOptions();
            
            for i = 1:length(allowedlist)
                obj.enabled.(allowedlist{i}) = true;
            end
            
            configureSingTests(obj,system,curvetype);
            
            list = system.getParameterList();
            for i = 1:length(list)
                obj.parameters.(list{i}) = 0;
                obj.freeparameters.(list{i}) = 0;
                obj.branchparameters.(list{i}) = 0;
            end
            
            list = system.getCoordinateList();
            for i = 1:length(list)
                obj.coordinates.(list{i}) = 0;
            end
            
            obj.userfunctions = system.getUserfunctions();
            
            
        end
        
        
        function list = getParameters(obj)
            list = fieldnames(obj.parameters);
        end
        function list = getCoordinates(obj)
            list = fieldnames(obj.coordinates);
        end
        
        function list = getCoordinateValues(obj)
            list = [];
            coords = getCoordinates(obj);
            for i = 1:length(coords)
                list = [list;  obj.coordinates.(coords{i})];
            end
        end
        
        function list = getParameterValues(obj)
            list = [];
            params = getParameters(obj);
            for i = 1:length(params)
                list = [list;  obj.parameters.(params{i})];
            end
        end
        
        
        function nr = getNrParameters(obj)
            nr = length(fieldnames(obj.parameters));
        end
        
        function list = getActiveParams(obj)
            list = [];
            params = obj.getParameters();
            for i = 1:length(params)
                if (obj.freeparameters.(params{i}))
                    list = [list i];
                end
            end
            
        end
        
        function nr = getNrCoordinates(obj)
            nr = length(fieldnames(obj.coordinates));
            
        end
        
        function b = isFreeParamsByIndex(obj,index)
            params = obj.getParameters();
            b = obj.freeparameters.(params{index});
        end
        
        function nr = getNrFreeParams(obj)
            nr = 0;
            params = obj.getParameters();
            for i = 1:length(params)
                if (obj.freeparameters.(params{i}))
                    nr = nr + 1;
                end
            end
            
        end
        
        function setParameter(obj , key, val)
            obj.parameters.(key) = val;
        end
        function setParameterByIndex(obj, index , val)
            list =  obj.getParameters();
            obj.setParameter( list{index} , val);
        end
        
        
        function setFreeParameter(obj , key, val)
            obj.freeparameters.(key) = val;
            obj.notify('freeParamChanged');
            
        end
        function setFreeParameterByIndex(obj , index, val)
            list =  obj.getParameters();
            obj.setFreeParameter( list{index} , val);
            
        end
        function val = getFreeParameter(obj,key)
            val = obj.freeparameters.(key);
        end
        function setBranchParameter(obj , key, val)
            obj.branchparameters.(key) = val;
        end
        function val = getBranchParameter(obj,key)
            val = obj.branchparameters.(key);
        end
        
        function setCoordinate(obj, key,val)
            obj.coordinates.(key) = val;
        end
        function val = getParameter(obj,key)
            val = obj.parameters.(key);
        end
        function setCoordinateByIndex(obj,index,val)
            list = obj.getCoordinates();
            obj.setCoordinate(list{index},val);
        end
        
        function val = getCoordinate(obj,key)
            val = obj.coordinates.(key);
        end
        function setMonitorSingularities(obj, key , bool)
            obj.singularities.(key) = bool;
        end
        function setMonitorSingularitiesByIndex(obj, index , bool)
            list = obj.getSingularitiesList();
            try
                obj.setMonitorSingularities(list{index},bool);
            catch test 
                disp(test);
            end
        end
        function bool = getMonitorSingularities(obj,key)
            bool = obj.singularities.(key);
        end
        
        function list = getSingularitiesList(obj)
            list = fieldnames(obj.enabled.singularities);
            
        end
        function nr = getNrOfEnabledSingularities(obj)
            nr = 0;
            sings = fieldnames(obj.singularities);
            for i = 1:length(sings)
                nr = nr +  obj.singularities.(sings{i});
            end
            
        end
        
        function list = getSettingsList(obj)
            list = fieldnames(obj.settings);
        end
        
        function setSetting(obj , key , val)
            obj.settings.(key) = val;
        end
        
        function val= getSetting(obj,key)
            val = obj.settings.(key);
        end
        
        function list = getJacobianList(obj)
            list = fieldnames(obj.jacobiandata);
        end
        
        function setJacobian(obj , key , val)
            obj.jacobiandata.(key) = val;
        end
        
        function val= getJacobian(obj,key)
            val = obj.jacobiandata.(key);
        end
        
        function setMultipliers(obj, val)
            obj.showmultipliers = val;
        end
        
        function val= getMultipliers(obj)
            val = obj.showmultipliers;
        end
        
        function bool = isEnabled(obj,sectionkeyword)
            bool = isfield(obj.enabled, sectionkeyword)  && (obj.enabled.(sectionkeyword));
        end
        function setEnabled(obj,sectionkeyword , bool)
            obj.enabled.(sectionkeyword) =  bool;
        end
        function bool = isTestEnabled(obj,testkeyword)
            bool = isfield(obj.enabled.singularities,testkeyword) && (obj.enabled.singularities.(testkeyword));
        end
        
        function bool = isFrozen(obj)
            bool = obj.frozen;
        end
        
        function ct = getCurrentCurveType(obj)
            ct = obj.currentcurvetype;
        end
        
        %userfunctions functions:
        function nr =  getNrUserfunctions(obj)
            nr = length(obj.userfunctions);
        end
        function name = getNameUserfunction(obj,index)
            name = obj.userfunctions(index).name;
        end
        
        function isvalid = isValidUserfunction(obj,index)
            isvalid = obj.userfunctions(index).valid;
        end
        function lbl = getLabelUserfunction(obj,index)
            lbl = obj.userfunctions(index).label;
        end
        function setEnabledUserfunction(obj,index , val)
            obj.userfunctions(index).state = val;
        end
        function b = isEnabledUserfunction(obj,index)
            b =  obj.userfunctions(index).valid && obj.userfunctions(index).state;
        end
        %
        function bool = userfunctionsEnabled(obj)
            bool = false;
            for i = 1:length(obj.userfunctions)
                if ((obj.userfunctions(i).valid) && (obj.userfunctions(i).state))
                    bool = true;
                    return;
                end
            end
        end
        function bool = hasValidUserfunctions(obj)
            bool = false;
            for i = 1:length(obj.userfunctions)
                if (obj.userfunctions(i).valid)
                    bool = true;
                    return
                end
            end
        end
        function uf = getUserfunctionsInfo(obj)
            uf = obj.userfunctions;
        end
        
        function index =  getUserFunctionIndex(obj, label)
            index = -1;
            for i = 1:length(obj.userfunctions)
                if strcmp(obj.userfunctions(i).label , label)
                    index = i;
                    return;
                end
            end
            
        end
        function configUserFunctions(obj, list)
            obj.userfunctions =  SystemSpace.setEnabledUserFunctions(list, obj.userfunctions);
        end
        
        function setTrajectOptions(obj)
            obj.showmultipliers = 0;
            list = fieldnames(obj.freeparameters);
            for i = 1:length(list)
                obj.freeparameters.(list{i}) = 0;
            end
            singlist = fieldnames(obj.singularities);
            
            for i = 1:length(singlist)
                obj.singularities.(singlist{i}) = 0;
            end
            
            for i = 1:length(obj.userfunctions)
                obj.userfunctions(i).state = 0;
            end
            
            obj.notify('freeParamChanged');
        end
        %%%%%%% %%%%% % % % %%%% % % %%%
    end
    
end

