classdef SelectPointsMenu < handle
    %SELECTPOINTSMENU Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        
        eventlisteners = {};
    end
    
    methods
        function obj = SelectPointsMenu(parent, pointtypes, session, varargin)
            obj.handle = uimenu(parent, 'Label' , 'Initial Point' , varargin{:});
            set(obj.handle,'DeleteFcn' , @(o,e) obj.destructor());
            
            list = {PointType('FP'), PointType('PD') ,PointType('LP') , PointType('NS') };

            for i = 1:length(list)
                uimenu(obj.handle, 'Label' , list{i}.getName() , 'Callback', @(o,e) session.setPointType(list{i}) , varargin{:});
            end
            
            
            codim2 = uimenu(obj.handle , 'Label' , 'Co-dimension 2' , 'Separator' , 'on');
           
	   list = { PointType('CP'),  PointType('GPD'),  PointType('CH'),  PointType('R1'),   PointType('R2'),  PointType('R3'),  PointType('R4'),  PointType('LPPD'),    PointType('LPNS'),  PointType('PDNS'),  PointType('NSNS')};


            for i = 1:length(list)
                uimenu(codim2 , 'Label' , list{i}.getName() , 'Callback', @(o,e) session.setPointType(list{i}) , varargin{:});
            end


            p = PointType('P');
            uimenu(obj.handle , 'Label' , p.getName() ,  'Callback', @(o,e) session.setPointType(p) , varargin{:} , 'Separator' , 'on');
 %           
	    p = PointType('CO');
	    uimenu(obj.handle , 'Label' , p.getName() ,  'Callback', @(o,e) session.setPointType(p) , varargin{:} , 'Separator' , 'on');
        end
        
        
        function destructor(obj)
            for i = 1:length(obj.eventlisteners)
                delete(obj.eventlisteners{i});
            end
            delete(obj);
            
        end
    end
        
end

function result = bool2str( bool)
if  (bool)
    result = 'on';
else
    result = 'off';
end
end
