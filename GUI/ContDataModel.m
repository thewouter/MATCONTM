classdef ContDataModel < handle
    % Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        continuation
        corrector
        stop
        
        backwards = 0;
        
        frozen = 0;
        autoder = 1;
    end
    
    events
        settingChanged
    end
    
    methods
        function obj = ContDataModel(varargin)
            obj.continuation.InitStepSize = DefaultValues.CONTINUERDATA.InitStepSize;
            obj.continuation.MinStepSize = DefaultValues.CONTINUERDATA.MinStepSize;
            obj.continuation.MaxStepSize = DefaultValues.CONTINUERDATA.MaxStepSize;
            
            obj.corrector.MaxNewtonIters = DefaultValues.CONTINUERDATA.MaxNewtonIters;
            obj.corrector.MaxCorrIters = DefaultValues.CONTINUERDATA.MaxCorrIters;
            obj.corrector.TestIters = DefaultValues.CONTINUERDATA.TestIters;
            obj.corrector.VarTolerance = DefaultValues.CONTINUERDATA.VarTolerance;
            obj.corrector.FunTolerance = DefaultValues.CONTINUERDATA.FunTolerance;
            obj.corrector.TestTolerance = DefaultValues.CONTINUERDATA.TestTolerance;
            obj.corrector.Adapt = DefaultValues.CONTINUERDATA.Adapt;
            
            obj.stop.MaxNumPoints = DefaultValues.CONTINUERDATA.MaxNumPoints;
            obj.stop.ClosedCurve = DefaultValues.CONTINUERDATA.ClosedCurve;
            obj.stop.NonCNFourier = DefaultValues.CONTINUERDATA.NonCNFourier;
            
            if (nargin >= 1)
                obj.frozen = varargin{1};
            end
        end
        
        function copyOver(obj,contdata)
            obj.continuation = contdata.continuation;
            obj.corrector = contdata.corrector;
            obj.stop  = contdata.stop;
            obj.notify('settingChanged');
        end
        function A = saveobj(obj)
            A.continuation = obj.continuation;
            A.corrector = obj.corrector;
            A.stop  = obj.stop;
        end
        
        
        function list = getContinuationDataList(obj)
            list = fieldnames(obj.continuation);
        end
        
        function setContinuationData(obj , key , val)
            if (~isempty(val))
                obj.continuation.(key) = val;
            end
        end
        
        function val= getContinuationData(obj,key)
            val = obj.continuation.(key);
        end
        
        function setBackwards(obj, backwards)
            if (~isempty(backwards)), obj.backwards = backwards; end
        end
        function val = getBackwards(obj)
            val = obj.backwards;
        end
        
        
        function list = getCorrectorDataList(obj)
            list = fieldnames(obj.corrector);
        end
        
        function setCorrectorData(obj , key , val)
            if (~isempty(val))
                obj.corrector.(key) = val;
            end
        end
        
        function val= getCorrectorData(obj,key)
            val = obj.corrector.(key);
        end
        
        function bool = getAutDerivative(obj)
            bool = obj.autoder;
        end
        
        function list = getStopDataList(obj)
            list = fieldnames(obj.stop);
        end
        
        function setStopData(obj , key , val)
            if (~isempty(val))
                obj.stop.(key) = val;
            end
        end
        
        function val= getStopData(obj,key)
            val = obj.stop.(key);
        end
        function b = isFrozen(obj)
            b = obj.frozen;
        end
        
    end
    
end

