classdef CurveType_X < handle
    %CURVETYPE_FP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function string = getName(obj)
            string = '';
        end
        function string = getLabel(obj)
            string = 'X';
        end
          
        function list = getNumericVarList(obj)
            list = {};
        end     
        %------------------------------------------------------
        function list = allowedStarterOptions(obj)
            list = {};
            
        end
        function nr = getReqNrFreeParams(obj)
           nr = 0; 
        end        
        function col = getDefaultColor(obj)
           col = 'white'; 
        end        
        function [list,minlist] = getTestfunctions(obj)
           list =   { };
           minlist = [];
        end     
        function fhandle = getActiveParamsRestriction(obj)
            fhandle = @(startdata) 0;
        end    
        function curvedef = getCurveDefinition(obj)
            curvedef = @() 0;
        end

        function list = getDependantGlobalVars(obj)
            list = {};
            mindim = [];
        end
        
        function list = getBranches(obj, pointtag,session)
               list = {};
        end          
        function mat = getSingMatrix(obj)
            mat = [];
        end
    end
end
