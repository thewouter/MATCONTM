classdef DefaultCurve < handle
    %DEFAULTCURVESELECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data
          
    end
    
    properties(Constant)
        ANY = 'ANY____';
        NEW = 'NEW____';
        
        NOTHING = 'NOTHING';
        
        
    end
    
    methods
        
        function obj = DefaultCurve()
                %obj.addDefault( INITPOINTLABEL,  PARENTCURVELABEL , initialisername )
		obj.addDefault( 'FP' , obj.ANY , 'init_FPm_FPm');
                obj.addDefault( 'BP' , obj.ANY , 'init_BPm_FPm');
                obj.addDefault( 'NS' , obj.ANY , 'init_NSm_NSm');
                obj.addDefault( 'PD' , obj.ANY , 'init_PDm_PDm');
                obj.addDefault( 'LP' , obj.ANY , 'init_LPm_LPm');
                
                obj.addDefault( 'R4' , 'NS' ,    'init_R4_LP4m1');
                obj.addDefault( 'CO' , obj.ANY ,   'init_Hom_Hom');
                obj.addDefault( 'LP_HE' , obj.ANY ,   'init_HetT_HetT');
                obj.addDefault( 'LP_HO' , obj.ANY ,   'init_HomT_HomT');
                obj.addDefault( 'P' , obj.ANY , 'Orbit');
            
            
        end
        
        
        
        function addDefault(obj,  detectedpointtype,  parentcurvetype , defaultcurvetype)
           obj.data.(detectedpointtype).(parentcurvetype) = defaultcurvetype; 
        end
        
        
        function initlabel = retrieveDefaultCurve(obj , pointtag , parentcurvetag)
            if (~isfield(obj.data, pointtag))
               initlabel = obj.NOTHING;
               return;
            end
            
            if (isempty(parentcurvetag))
               parentcurvetag = obj.NEW; 
            end
            
            if (isfield(obj.data.(pointtag) , parentcurvetag))
               initlabel =  obj.data.(pointtag).(parentcurvetag);
               return;
            elseif (isfield(obj.data.(pointtag) , obj.ANY ))
                initlabel = obj.data.(pointtag).(obj.ANY);
                return;
            else
                initlabel = obj.NOTHING;
                
            end
            
            
        end
        
        
        
        
        
    end
    
end

