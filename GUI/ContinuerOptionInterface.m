classdef ContinuerOptionInterface < handle
    %CONTINUEROPTIONINTERFACE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mapping
        startdata
        contdata
        
    end
    
    methods
        
        
        function obj = ContinuerOptionInterface(contdatamodel, startdatamodel)
            obj.startdata = startdatamodel;
            obj.contdata  = contdatamodel;
            
            obj.mapping.InitStepsize = @() obj.contdata.getContinuationData('InitStepSize');
            obj.mapping.MinStepsize = @() obj.contdata.getContinuationData('MinStepSize');
            obj.mapping.MaxStepsize = @() obj.contdata.getContinuationData('MaxStepSize'); 
            
            obj.mapping.MaxNewtonIters = @() obj.contdata.getCorrectorData('MaxNewtonIters');
            obj.mapping.MaxCorrIters = @() obj.contdata.getCorrectorData('MaxCorrIters');
            obj.mapping.MaxTestIters = @() obj.contdata.getCorrectorData('TestIters');
            obj.mapping.VarTolerance = @() obj.contdata.getCorrectorData('VarTolerance');
            obj.mapping.FunTolerance = @() obj.contdata.getCorrectorData('FunTolerance');
            obj.mapping.TestTolerance = @() obj.contdata.getCorrectorData('TestTolerance');
            obj.mapping.Adapt = @() obj.contdata.getCorrectorData('Adapt');
            
            obj.mapping.MaxNumPoints = @() obj.contdata.getStopData('MaxNumPoints');
            obj.mapping.ClosedCurve = @() obj.contdata.getStopData('ClosedCurve');
            
            
            obj.mapping.ActiveParams = @() obj.getAdaptParam();
            obj.mapping.IgnoreSingularity = @() ContinuerOptionInterface.getIgnoreSingularity(obj.startdata);
            
            obj.mapping.Singularities = @() length(ContinuerOptionInterface.getIgnoreSingularity(obj.startdata)) < length(obj.startdata.getSingularitiesList);
            
            obj.mapping.Increment  = @() obj.startdata.getJacobian('increment') ;
            obj.mapping.Multipliers = @() obj.startdata.getMultipliers();
            %   obj.mapping.IterationN = @() obj.startdata.getSetting('iterationN');
            %obj.mapping.ADnumber = @() obj.startdata.getSetting('ADnumber');
            
            obj.mapping.Backward = @() obj.contdata.getBackwards();
            
            %FIXME todo: reverse |
            obj.mapping.Userfunctions =  @() obj.startdata.userfunctionsEnabled();
            obj.mapping.UserfunctionsInfo = @() obj.startdata.getUserfunctionsInfo();

        
            %AutDer
            %boolean indicating use of automatic differentiation in the
            %computation of normal form coeff

            obj.mapping.AutDerivative = @() obj.contdata.getAutDerivative() ;
            % an int number that indicates the use of automatic
            % differentation when the iteration number of the map equals or
            % exceeds this number
            obj.mapping.AutDerivativeIte =  @() obj.startdata.getSetting('ADnumber');
            
        end
        
        
        function out = subsref(obj , S) 
            if (isfield(obj.mapping , S(1).subs ))  
                getter = obj.mapping.(S(1).subs);
                out = getter();
            else
                out = [];
            end
        end
        
        function list = getAdaptParam(obj)
            list = [];
            params = obj.startdata.getParameters();
            for i = 1:length(params)
                if (obj.startdata.getFreeParameter(params{i}))
                    list(end+1) = i;
                end
            end
        end
        

        
        function bool = singularityMatrix(obj)
            bool  = 1;  %FIXME , todo
        end
        
        
        function doDisplay(obj)
            names = fieldnames(obj.mapping);
            
            for i = 1:length(names)
               fprintf(names{i});
               f = obj.mapping.(names{i});
               
               res = f();
               if isempty(res)
                   disp('       []');
                   disp(' ');
               else
                   disp(res);
               end
            end
            
        end
        
               
%          InitStepsize:
%           MinStepsize: 
%           MaxStepsize: 
%          MaxCorrIters: 
%        MaxNewtonIters: 
%          MaxTestIters:
%          MoorePenrose: []
%         SymDerivative: []
%        SymDerivativeP: []
%             Increment: 
%          FunTolerance: 
%          VarTolerance: 
%         TestTolerance: 
%         Singularities: 
%          MaxNumPoints: 
%              Backward: []
%           CheckClosed: 
%         TestFunctions: []
%             WorkSpace: []
%              Locators: []
%                 Adapt:
%     IgnoreSingularity:
%          ActiveParams:
%           Multipliers:
%           Eigenvalues: []
%         Userfunctions: 
%     UserfunctionsInfo:
%                   PRC: []
%                  dPRC: []
%                 Input: []
%            IterationN:
%              ADnumber:     
%         
        
        
        
        
        
        
        
        
        
    end
    
    methods(Static)
        function [startdata, contdata] = reconstructData(system , curvetype , cds, P0, iterationN, firstpoint)
            startdata = StartDataModel(system,curvetype);
            contdata = ContDataModel(true);
            
            contdata.setContinuationData('InitStepSize' , cds.options.InitStepsize );
            contdata.setContinuationData('MinStepSize'  , cds.options.MinStepsize  );
            contdata.setContinuationData('MaxStepSize'  , cds.options.MaxStepsize  );
            contdata.setCorrectorData('MaxNewtonIters'  , cds.options.MaxNewtonIters );
            contdata.setCorrectorData('MaxCorrIters'    , cds.options.MaxCorrIters );
            contdata.setCorrectorData('TestIters'       , cds.options.MaxTestIters );
            contdata.setCorrectorData('VarTolerance'    , cds.options.VarTolerance );
            contdata.setCorrectorData('FunTolerance'    , cds.options.FunTolerance );
            contdata.setCorrectorData('TestTolerance'   , cds.options.TestTolerance );
            contdata.setCorrectorData('Adapt'           , cds.options.Adapt );
            contdata.setStopData('MaxNumPoints' , cds.options.MaxNumPoints );
            contdata.setBackwards(cds.options.Backward);
            
            if(isfield(cds.options,'ClosedCurve')), contdata.setStopData('ClosedCurve'  , cds.options.ClosedCurve); end
            
            for i = cds.options.ActiveParams
                startdata.setFreeParameterByIndex(i , true);
            end
            
            for i = cds.options.IgnoreSingularity
                startdata.setMonitorSingularitiesByIndex(i,false);
            end
            if (~isempty(cds.options.Increment)) , startdata.setJacobian('increment' , cds.options.Increment); end
            if (~isempty(cds.options.Multipliers)) , startdata.setMultipliers(cds.options.Multipliers); end
             
            %Probleemgeval:
            startdata.setSetting('iterationN' , iterationN);
            if (~isempty(cds.options.AutDerivativeIte)) , startdata.setSetting('ADnumber', cds.options.AutDerivativeIte); end
            %%%%%%%%%%%%%%%%%%%%%
            
            for i = 1:length(P0)
               startdata.setParameterByIndex(i , P0(i)); 
            end
            
            coordlist = system.getCoordinateList();
            for i = 1:length(coordlist)
               startdata.setCoordinate( coordlist{i} , firstpoint(i)); 
            end
            if (isfield(cds.options,'Userfunctions') && isfield(cds.options,'UserfunctionsInfo'))
                startdata.configUserFunctions(   SystemSpace.getEnabledUserFunctions( cds.options.Userfunctions , cds.options.UserfunctionsInfo));
            end
           
        end
        
        function list = getIgnoreSingularity(startdata)

            list = [];
            singlist = startdata.getSingularitiesList();
            for i = 1:length(singlist)
               if (~ startdata.getMonitorSingularities( singlist{i} ))
                    list(end+1) = i;
               end
            end
            
        end
        
        function list = getActiveParams(startdata)
            list = [];
            params = startdata.getParameters();
            for i = 1:length(params)
                if (startdata.getFreeParameter(params{i}))
                    list(end+1) = i;
                end
            end            
            
        end
    end
end



