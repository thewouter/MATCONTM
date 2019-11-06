classdef System < handle
    %SYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name = ''
        
        coordinatelist
        paramlist
        fhandle
        
        location
        derinfostr
        equations

        userfunctionsInfo = [];
        
        tempstorage = struct();
    end
    
    methods
        function obj = System(varargin)
            if (nargin < 7)
                obj.coordinatelist = {};
                obj.paramlist = {};
                obj.fhandle = @() 0;
                obj.location = '';
                obj.name = '<none>';
                obj.derinfostr = '';
                obj.equations = '';
            else
                assert(nargin == 7);
                obj.fhandle        = varargin{1};
                obj.coordinatelist = varargin{2};
                obj.paramlist      = varargin{3};
                obj.name           = varargin{4};
                obj.location       = varargin{5};
                obj.derinfostr     = der2str(varargin{6});
                obj.equations      = varargin{7};
                obj.setUp();
            end
        end
        
        
        function name = getName(obj)
            name = obj.name;
        end
        
        function list = getCoordinateList(obj)
           list = obj.coordinatelist; 
        end
        
        function list = getParameterList(obj)
           list = obj.paramlist; 
        end
        
        function co = getCoordinateByIndex(obj,index)
           co = obj.coordinatelist{index}; 
        end
        
        function pa = getParameterByIndex(obj,index)
           pa = obj.paramlist{index}; 
        end
        function nr = getNrCoordinates(obj)
            nr = length(obj.coordinatelist);
        end
        function nr = getNrParameters(obj)
           nr = length(obj.paramlist); 
        end
        
        function fhandle = getFunctionHandle(obj)
           fhandle = obj.fhandle;
        end
        function str = getDerInfo(obj)
            str = obj.derinfostr;
        end
        function eq = getEquations(obj)
           eq = obj.equations; 
        end
        
        function path = getPath(obj)
           path = obj.location; 
        end
        function s = getSystemFunction(obj)
             s = MatcontMSystem(obj.fhandle);
        end
        
        function b = cmp(obj,sys)
           b = ~isempty(sys) && strcmp(obj.location, sys.location); 
        end
        
        function setUp(obj)
           if (exist( obj.location  ,'dir') ~= 7)
                mkdir([obj.location '/']);
           end
           diagrams = InspectorDiagram.getDiagramList(obj.location);
           if (isempty(diagrams))
               mkdir([obj.location '/diagram']);
           else
           end
        end
        
        function path = getDefaultDiagramPath(obj)
            diagrams = InspectorDiagram.getDiagramList(obj.location);
            
            if isempty(diagrams)
                obj.setUp();
                diagrams = InspectorDiagram.getDiagramList(obj.location);
            end
            path = [obj.location '/' diagrams{end}]; %youngest diagram
        end
        
        function setUserfunctions(obj, equations   , userfunctionsInfo)
           
           for i = length(equations):-1:1
                if (isempty(equations{i}))
                    userfunctionsInfo(i).valid = 0;
                    userfunctionsInfo(i).state = 0;
                else
                    userfunctionsInfo(i).equation = equations{i};
                    userfunctionsInfo(i).state = 0;
                    userfunctionsInfo(i).valid = 1;
                end
           end
           
           obj.userfunctionsInfo = userfunctionsInfo;
        end
        
        function list = getDiagramList(obj)
            list = InspectorDiagram.getDiagramList( obj.location );
        end
        
        function uf = getUserfunctions(obj)
            uf = obj.userfunctionsInfo;
        end
        
        function saveState(obj, newstate)
            load([obj.location '.mat']);
            state = newstate;
            save([obj.location '.mat'] , 'gds' , 'state');
        end
        
        function state = getState(obj)
            load([obj.location '.mat']);
            if  ~exist('state' , 'var')
               state = []; 
            end
        end
        
    end
    
end

function str = der2str(der)
for i=1:5
    for j=1:4
        if (der(j,i)==1)
            switch j
                case 1
                    str(i)='N';
                case 3
                    str(i)='R';
                case 4
                    if (exist('sym')==2)
                        str(i)='S';
                    else
                        str(i)='F';
                    end
            end
        end
    end
end
end
