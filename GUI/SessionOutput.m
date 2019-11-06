classdef SessionOutput
    %SESSIONOUTPUT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        session;
        enabled = 1;
        
        mainhandle;
        
        pauseoption;
        SPECIAL = 1;
        ALWAYS = 2;
        NEVER = 3;
        
        currentstate = 0;
        READY = 0;
        COMPUTING = 1;
        PAUSED = 2;
        ENDED = 3;
        
        doStop;
        doPause;
        
        plotpointsperiod = 1;
        
        statushandle
        outputhandle
        
        model;
        
        plotlist = {};
        numericoutput = [];
        
        msgs = {};
    end
    
    
    methods
        
        function obj = SessionOutput(session)
            obj.session = session;
            obj.mainhandle = figure('Visible','off','UserData', 0); %HACK
            obj.pauseoption = session.configmanager.getValue('suspend');
            obj.doStop = 0;
            obj.doPause = 0;
            obj.model = SessionOutputModel();
            obj.plotpointsperiod = session.configmanager.getValue('plotoutput');
     
            %input numeric
            numeric = session.getNumeric();
            if isempty(numeric)
                obj.numericoutput = [];
            else
               obj.numericoutput = NumericOutput(numeric , session); 
            end
            obj.plotlist = session.getPlotManager().preparePlotList();
        end

        function plotlist = releasePlotList(obj)
        global sOutput
            plotlist = sOutput.plotlist;
            sOutput.plotlist = {};
        end
        
        
        function output(obj,xout,s,hout,fout,ind)
        global sOutput

            if (sOutput.enabled)
                 if (~isempty(obj.numericoutput))
                    obj.numericoutput.output(xout , s , hout, fout , ind); 
                 end
                 
                 if (~isempty(hout))
                     for i = 1:length(obj.plotlist)
                        obj.plotlist{i}.output(obj.session, xout,s,hout,fout,ind); 
                     end
                 end
            end
        end
        
        
        function setDuration(obj, string)
        global sOutput
            disp(['duration: ' string]);
        end
        function setStatus(obj, string)
        global sOutput
            set(obj.statushandle , 'String' ,  string);
        end
        
        function endRun(obj)
        global sOutput
            sOutput.setCurrentState(sOutput.ENDED);
            sOutput.setStatus('Finished');
        end
        
        function doStop = checkPauseResumeStop(obj, s_index , s_msg , it)
        global sOutput 
            doStop = sOutput.doStop;
            if (doStop)
                sOutput.doStop = 0;
                return;
            end %doStop = 0;
            
            if (sOutput.doPause)
                sOutput.waitForResume();
            end
            
            if (sOutput.pauseoption == sOutput.SPECIAL)
                if ((it > 2) && ( s_index == (it - 1) )) %first point excluded(it >2)
                    sOutput.pause();
                    sOutput.waitForResume(s_msg);
                end
                
            elseif (sOutput.pauseoption == sOutput.ALWAYS)
                sOutput.pause();
                if ((it > 2) && ( s_index == (it - 1) ))
                    sOutput.waitForResume();
                else
                    sOutput.waitForResume(s_msg);
                end
             end
            
        end
        
        function performStop(obj)
        global sOutput
            sOutput.doStop = 1;
            if (sOutput.currentstate == sOutput.PAUSED)
               sOutput.unpause(); 
            end
        end
        
        
        function waitForResume(obj,msg)
        global sOutput
            sOutput.setCurrentState(sOutput.PAUSED);
            
            if (nargin == 2)
                
                statusmsg = ['Paused, ' strtrim(msg)];
            else
                statusmsg = 'Paused'; 
            end
            sOutput.setStatus(statusmsg);
            waitfor(sOutput.mainhandle,'UserData',0);
            sOutput.setCurrentState(sOutput.COMPUTING);
            sOutput.setStatus('Computing ...');
            sOutput.doPause = 0;
        end
        
        
        function pause(obj)
        global sOutput
            set(sOutput.mainhandle, 'UserData' , 1);
            sOutput.doPause = 1;
        end
        
        
        function unpause(obj)
        global sOutput
            sOutput.doPause = 0;
            set(sOutput.mainhandle, 'UserData' , 0);
        end
        
        function n = getPlotPointsInterval(obj)
           n = obj.plotpointsperiod; 
        end
        
        
        function setPauseAlways(obj)
        global sOutput
            sOutput.pauseoption = sOutput.ALWAYS;
            sOutput.model.notify('settingChanged');
        end
        function setPauseSpecial(obj)
        global sOutput
            sOutput.pauseoption = sOutput.SPECIAL;
            sOutput.model.notify('settingChanged');
        end       
        function setPauseNever(obj)
        global sOutput
            sOutput.pauseoption = sOutput.NEVER;
            sOutput.model.notify('settingChanged');
        end 
        
        function  b = isPauseNever(obj)
        global sOutput
            b = sOutput.pauseoption == sOutput.NEVER;
        end
        function  b = isPauseAlways(obj)
        global sOutput
            b = sOutput.pauseoption == sOutput.ALWAYS;
        end        
        function  b = isPauseSpecial(obj)
        global sOutput
            b = sOutput.pauseoption == sOutput.SPECIAL;
        end       
        
        function setCurrentState(obj,state)
        global sOutput
            sOutput.currentstate = state;
            sOutput.model.notify('stateChanged');
        end
        function b = hasEnded(obj)
        global sOutput
            b = (sOutput.currentstate == obj.ENDED);
        end
        
    function setStatusHandle(obj, statushandle)
    global sOutput
       sOutput.statushandle = statushandle; 
    end
    function setOutputHandle(obj, outputhandle)
    global sOutput
       sOutput.outputhandle = outputhandle; 
    end    
    end
    methods(Static)
        function s = vector2str(varargin)
            s = ['( ' sprintf('%f ',varargin{1}) ')'];
        end
        function setupSimplePrintconsole
             global sOutput;
             sOutput.outputhandle = [];
             sOutput.msgs = {};
        end
    end
end


