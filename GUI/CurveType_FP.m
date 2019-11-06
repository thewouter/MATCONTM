classdef CurveType_FP < handle
    %CURVETYPE_FP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        branches
    end
    
    methods
    %     L = [ 'NS  ';'PD  '; 'LP  ';'BP  ' ];

    function obj = CurveType_FP()
       obj.branches = struct();
       %Branch(pttag, cttag , initfunc, periodmult, conditional , name)
       obj.branches.P  = { Branch('FP','FP', @init_FPm_FPm , 1 , false,'D') };
       obj.branches.FP = { Branch('FP','FP', @init_FPm_FPm , 1 , false,'D') };
       obj.branches.PD = { Branch('PD','FP', @init_PDm_FP2m , 2 , false,'SH') ,...
                           Branch('PD','FP', @init_FPm_FPm , 1 , false, 'D')};
                       
       obj.branches.BP = { Branch('BP','FP', @init_BPm_FPm , 1 , false,'SH'),...
                           Branch('BP','FP', @init_FPm_FPm , 1 , false, 'D')};
                       
       obj.branches.NS = { Branch('NS','FP', @init_FPm_FPm,  1 , false, 'D')};
       obj.branches.LP = { Branch('LP','FP', @init_FPm_FPm,  1 , false, 'D')};

       obj.branches.CP  = {   Branch('CP','FP', @init_FPm_FPm,  1 , false, 'D')};
       obj.branches.GDP  = {  Branch('GDP','FP', @init_FPm_FPm,  1 , false, 'D')};
       obj.branches.CH  = {   Branch('CH','FP', @init_FPm_FPm,  1 , false, 'D')};
       obj.branches.R1  = {   Branch('R1','FP', @init_FPm_FPm,  1 , false, 'D')};
       obj.branches.R2  = {   Branch('R2','FP', @init_FPm_FPm,  1 , false, 'D')};
       obj.branches.R3  = {   Branch('R3','FP', @init_FPm_FPm,  1 , false, 'D')};
       obj.branches.R4  = {   Branch('R4','FP', @init_FPm_FPm,  1 , false, 'D')};
       obj.branches.LPPD  = { Branch('LPPD','FP', @init_FPm_FPm,  1 , false, 'D')};
       obj.branches.LPNS  = { Branch('LPNS','FP', @init_FPm_FPm,  1 , false, 'D')};
       obj.branches.PDNS  = { Branch('PDNS','FP', @init_FPm_FPm,  1 , false, 'D')};
       obj.branches.NSNS  = { Branch('NSNS','FP', @init_FPm_FPm,  1 , false, 'D')};
    end
    
    
        function string = getName(obj)
            string = 'Fixed Point';
        end
        function string = getLabel(obj)
            string = 'FP';
        end
        
        %------------------------------------------------------
        function list  = allowedStarterOptions(obj)
            list = {'coordinates' , 'parameters' , 'ADnumber' , 'jacobian' , 'iterationN' , 'multipliers' ,'userfunction' , 'testfunctions' , 'amplitude' };
            
        end
        function [list,mindim] = getTestfunctions(obj)
            list =    {'NS' , 'PD' , 'LP' , 'BP'};
            mindim =  [ 2   ,   1    ,    1   ,   1 ];
        end
        
        function list = getNumericVarList(obj)
            list = {'coordinates','parameters','testfunctions','multipliers' ,'current_stepsize' , 'user_functions' , 'npoints'};
        end
        
        
        function list = getDependantGlobalVars(obj)
           list = {'cds','fpmds'}; 
        end
        
        
        function nr = getReqNrFreeParams(obj)
           nr = 1; 
        end
        

        function curvedef = getCurveDefinition(obj)
           curvedef = @fixedpointmap; 
        end
        
        function col = getDefaultColor(obj)
           col = DefaultValues.CURVECOLOR.FP; 
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
end

