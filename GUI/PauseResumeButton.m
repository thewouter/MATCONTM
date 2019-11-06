classdef PauseResumeButton < handle
    %EDITBOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        endfunction
        eventlistener = [];
    end
    
    methods
        
        
        function obj = PauseResumeButton(parent , endfunction,  varargin )
        global sOutput
            obj.handle = uicontrol(parent , 'Style' , 'pushbutton'  , 'Callback' , @(src,ev) obj.buttonPushed(), varargin{:} ); 
            obj.eventlistener = sOutput.model.addlistener('stateChanged' , @(o,e) obj.updateLabel());
            set(obj.handle,'DeleteFcn' , @(o,e) obj.destructor());
            obj.endfunction = endfunction;
            obj.updateLabel();
        end
        
        
        function updateLabel(obj)
        global sOutput
            if (sOutput.currentstate == sOutput.PAUSED)
               set(obj.handle , 'String' , 'Resume');
            elseif(sOutput.currentstate == sOutput.COMPUTING)
               set(obj.handle, 'String' , 'Pause');
            elseif (sOutput.currentstate == sOutput.ENDED)
              set(obj.handle , 'String' , 'View Curve');
            else
               set(obj.handle, 'String' , 'Pause');
           end
        end
        
        function buttonPushed(obj)
        global sOutput
           if (sOutput.currentstate == sOutput.PAUSED)
               sOutput.unpause();
           elseif (sOutput.currentstate == sOutput.COMPUTING)
               sOutput.pause();
           elseif (sOutput.currentstate == sOutput.ENDED)
               feval(obj.endfunction)
           else
               sOutput.pause();
           end
        end
        
        
        function destructor(obj)
           %D disp(['Destructor: ' mfilename]);
           delete(obj.eventlistener);
           delete(obj);
        end
        
    end
    
end

