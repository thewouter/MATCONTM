classdef CurveType_HO < handle
    %CURVETYPE_PD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        branches
        
    end
    
    methods
        function obj = CurveType_HO()
           obj.branches = struct(); 
	       obj.branches.CO = { Branch('CO' , 'HO' , @init_Hom_Hom , 1 , false , 'HCO') };   
           obj.branches.LP_HO = { Branch('LP_HO' , 'HO' , @init_Hom_Hom , 1 , false , 'HCO') };  
        end
        
        
        function string = getName(obj)
            string = 'Homoclinic Connection';
        end
        function string = getLabel(obj)
            string = 'HO';
        end
        function col = getDefaultColor(obj)
           col =  DefaultValues.CURVECOLOR.HO;
        end
        function list = getDependantGlobalVars(obj)
            list = {'cds' , 'homds'};
        end

        function curvedef = getCurveDefinition(obj)
            curvedef = @homoclinic;
        end

        
        function list = getNumericVarList(obj)
            list = {'coordinates','parameters','testfunctions','current_stepsize' ,  'user_functions' , 'npoints'};
        end            

        %------------------------------------------------------
        function list  = allowedStarterOptions(obj)
            list = {'coordinates' , 'parameters' , 'ADnumber' , 'jacobian' , 'iterationN' ,  'testfunctions' , 'amplitude' };
        end
        
        function [list,mindim] = getTestfunctions(obj)
           list =   {'LP', 'BP'};
           mindim = [ 1   ,  Inf ];
        end  
        
        
        function nr = getReqNrFreeParams(obj)
           nr = 1; 
        end       
        
        
        function list = getBranches(obj, pointtag,session)
           if (isfield(obj.branches,pointtag))
               list = obj.branches.(pointtag);
           else
               list = {};
           end
            
        end   
        function mat = getSingMatrix(obj)
           out = feval(obj.getCurveDefinition());
           mat = feval(out{9});
        end
    end
methods(Static)
    function s = fixS(x,~,s,~,~ , curvelabel)
        global homds;
        global hetds;
        
        if (strcmp(curvelabel, 'HO'))
            ds = homds;
        else
            ds = hetds;
        end

        for i = 1:length(s)
            if (ismember(strtrim(s(i).label) , {'LP' , 'BP'}))
                s(i).label = [strtrim(s(i).label) , '_' , curvelabel];
                s(i).data.NU = ds.nu;
                s(i).data.NS = ds.ns;
                Yi = ds.npoints * ds.nphase; 
                
                s(i).data.riccatidata =  x((Yi+1):(end-1), s(i).index);
            end
            
        end
    end

    
end
    
end
