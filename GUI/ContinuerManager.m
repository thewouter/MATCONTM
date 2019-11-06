classdef ContinuerManager
    %CONTINUERMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        continuer
    end
    
    methods
        
        function obj = ContinuerManager()
            obj.continuer = @cont;
        end
        
        function cont(obj , session , direction , launchmonitorwindow)
            global sOutput;
            if (nargin < 4), launchmonitorwindow = true; end
            curve = session.currentcurve;
            
            session.getContData().setBackwards(~direction);
            curvetype = session.getCurveType();
            
            
            
            startdata = session.getStartData();
            
            %do sanity check
            reqparam = curvetype.getReqNrFreeParams();
            if (startdata.getNrFreeParams() ~= reqparam)
                errordlg([ num2str(reqparam) ' active parameter are needed for a ' curvetype.getLabel() '-curve continuation'], 'Error in number of active parameters');
                return
            end
            
            bm = session.getBranchManager();
            if (~ bm.validSelectionMade())
                errordlg('No branch selected' , 'Error');
                return
            end
            
            % end sanity check
            if (curve.hasFile())
                %anonymize
                session.currentcurve = session.curvemanager.getEmptyCurveFrom(curve.getLabel());
                curve = session.currentcurve;
            else
                session.getCurveManager().setUnnamed(curve);
            end
            
            x0 = startdata.getCoordinateValues();
            par = startdata.getParameterValues();
            systemhandle = session.getSystem().getFunctionHandle();
            
            
            curve.loadGlobalVars(curvetype);
            
            session.lock();
            
            %iteration number initial point
            nIteration = startdata.getSetting('iterationN');
            
            
            [x0 , v0] = bm.performInit(session, curve, x0 , par, systemhandle, nIteration);
            
            if isempty(x0)
                session.unlock();
                return;
            else
                multiplyIterationN = bm.getMultiplyIterationN();
            end
            
            if (launchmonitorwindow)
                sOutput = SessionOutput(session );
                MonitorPanel(session);
            end
            
            [x , v , s , h , f] = ...
                obj.continuer(    curvetype.getCurveDefinition() ...
                , x0 , v0 , ...
                session.optioninterface  );
            
            if (size(x,2) > 1) %if number of points greater than 1, (includes x=[]-case)
                
                ctlbl = curvetype.getLabel();
                if (ismember(ctlbl , {'HE' , 'HO'}))
                    s = CurveType_HO.fixS(x,v,s,h,f , ctlbl);
                end
                
                curve.setData(x,v,s,h,f);
                curve.setInitData(  bm.getCurrentBranchLabel() ,   multiplyIterationN);
    		curve.setPointType(session.getPointType());
		curve.setCurveType(session.getCurveType());
            
                curve.saveGlobalVars(curvetype);
                session.getCurveManager().name(startdata , session.getContData() , nIteration * multiplyIterationN);
                session.getCurveManager().save(curve);
                session.notify('stateChanged');
                %session.starterdata.notify('settingChanged');
            end
            
            session.unlock();
            
        end
        
        function cont_extend(obj, session, launchmonitorwindow)  %geen mogelijk voor nieuwe opties.. fix ?
            global sOutput;
            if (nargin < 3), launchmonitorwindow = true; end
            
            c = session.currentcurve;
            curvetype = c.getCurveType(); %get ct from curve instead of session
            
            session.lock();
            
            
            
            c.loadGlobalVars(curvetype);
            
            if (launchmonitorwindow)
                sOutput = SessionOutput(session );
                MonitorPanel(session);
            end
            
            [x , v , s , h , f]  = ...
                obj.continuer( c.x , c.v , c.s , c.h, c.f , c.globals.cds);
            
            if ~isempty(x)
                ctlbl = curvetype.getLabel();
                if (ismember(ctlbl , {'HE' , 'HO'}))
                    s = CurveType_HO.fixS(x,v,s,h,f , ctlbl);
                end
                c.setData(x,v,s,h,f);
                c.saveGlobalVars(curvetype);
    		%curve.setPointType(session.getPointType()); %already ok
		%curve.setCurveType(session.getCurveType()); %already ok
                session.getCurveManager().save(c);
                %session.notify('stateChanged');
            end
            
            session.unlock();
        end
        
        function orbit(obj , session, pointplot)
            global sOutput
            launchmonitorwindow = true;
            
            
            startdata = session.getStartData();
            contdata = session.getContData();
            
            curve = session.currentcurve;
            
            if (curve.hasFile())
                %anonymize
                session.currentcurve = session.curvemanager.getEmptyCurveFrom(curve.getLabel());
                curve = session.currentcurve;
            else
                session.getCurveManager().setUnnamed(curve);
            end            
            
            
            %end
            %set up sessionOutput:
            
            x0 = startdata.getCoordinateValues();
            x_len = length(x0);
            
            P0 = startdata.getParameterValues();
            par = num2cell(startdata.getParameterValues());
            
            
            
            iterationN = startdata.getSetting('iterationN');
            
            systemhandle = session.getSystem().getFunctionHandle();
            handles = feval(systemhandle);
            fun_eval = handles{2};
            
            npoints = session.getStartData.getSetting('orbitpoints');
            session.lock();
            
            sOutput.setStatus('Computing ...');
            
            
            if (launchmonitorwindow)
                MonitorPanel(session);
                drawnow;
            end
            
            x = zeros(x_len,npoints);
            
            x(:,1) = x0;
            s = struct();
            
            s(1).label = 'P';
            s(1).index = 1;
            s(1).data = [];
            s(1).msg = 'Start Point';
            
            sOutput.output(x, s ,[] , [] ,1);
            printconsole('Computing orbit...\n');
            printconsole([ sprintf('x_(%d) = ', 1) SessionOutput.vector2str(x(:,1)) '\n' ]);
            pointplot.outputPoint(x, [] , [], 1 , {} , SessionOutput.vector2str(x(:,1)));
            
            drawnow;
            doStop = sOutput.checkPauseResumeStop(s(1).index , s(1).msg ,1);
            if doStop~=0, npoints = 1;end  %npoints = i ---> end of mainloop
            
            
            i = 2;
            while (i <= npoints)
                x(:,i) =  evalf(fun_eval, iterationN, x(:,i-1), par);
                s(i) = struct('label' , 'P' , 'index' , i , 'data' , [] , 'msg' , 'Point');
                
                sOutput.output(x, s(i) ,[] , [] ,i);
                
                pointplot.output(session, x, s(i) , [] , [] , i);
                pointplot.outputPoint(x, [] , [], i , {} , SessionOutput.vector2str(x(:,i)));
                
                printconsole([ sprintf('x_(%d) = ', i) SessionOutput.vector2str(x(:,i)) '\n' ]);
                drawnow;
                doStop = sOutput.checkPauseResumeStop(s(i).index , s(i).msg ,i);
                if doStop~=0, npoints = i;end  %npoints = i ---> end of mainloop
                
                
                i=i+1;
            end
            
            printconsole('npoints curve = %d\n', npoints);
            sOutput.endRun();
            x = x(:,1:npoints);
            
            
            global ods cds
            ods.P0 = P0;
            cds.options = contmrg( contset , session.optioninterface);
            ods.Niterations  = iterationN;
            
            curve.setData(x,[],s,zeros(length(x0) , npoints),[]);
            curve.saveGlobalVars(session.getCurveType());
    	    curve.setPointType(session.getPointType()); 
	    curve.setCurveType(session.getCurveType());
            session.getCurveManager().name(startdata , session.getContData(), iterationN);
            session.getCurveManager().save(curve);
            session.notify('stateChanged');
            
            session.unlock();
        end
        
        function orbit_extend(obj , session, pointplot)
            global sOutput
            launchmonitorwindow = true;
            
            curve = session.currentcurve;
            x0 = curve.x(:,end);
            x_len = length(x0);
            P0 = curve.extractP0();
            par = num2cell(P0);
            iterationN = curve.extractIterationN();
            
            systemhandle = session.getSystem().getFunctionHandle();
            handles = feval(systemhandle);
            fun_eval = handles{2};
            
            npoints = session.getStartData.getSetting('orbitpoints');
            session.lock();
            
            sOutput.setStatus('Computing ...');
            
            
            if (launchmonitorwindow)
                MonitorPanel(session);
                drawnow;
            end
            
            
            
            %%% CODEDUP %%%

            totallen = size(curve.x,2) + npoints;
            i = size(curve.x,2);
            x = [curve.x , zeros(x_len,npoints)];
            s = curve.s;
            
            s(i).msg = 'Extend Point';
            
            sOutput.output(x, s ,[] , [] ,i);
            printconsole('Computing orbit (extend)...\n');
            printconsole([ sprintf('x_(%d) = ', i) SessionOutput.vector2str(x(:,i)) '\n' ]);
            pointplot.outputPoint(x, [] , [], i , {} , SessionOutput.vector2str(x(:,i)));
            
            drawnow;
            doStop = sOutput.checkPauseResumeStop(s(i).index , s(i).msg ,i);
            if doStop~=0, totallen = i;end  %---> end of mainloop
            
            
            i = i + 1;
            while (i <= totallen)
                x(:,i) =  evalf(fun_eval, iterationN, x(:,i-1), par);
                s(i) = struct('label' , 'P' , 'index' , i , 'data' , [] , 'msg' , 'Point');
                
                sOutput.output(x, s(i) ,[] , [] ,i);
                
                pointplot.output(session, x, s(i) , [] , [] , i);
                pointplot.outputPoint(x, [] , [], i , {} , SessionOutput.vector2str(x(:,i)));
                
                printconsole([ sprintf('x_(%d) = ', i) SessionOutput.vector2str(x(:,i)) '\n' ]);
                drawnow;
                doStop = sOutput.checkPauseResumeStop(s(i).index , s(i).msg ,i);
                if doStop~=0, totallen = i;end  % ---> end of mainloop
                
                
                i=i+1;
            end
            
            printconsole('npoints curve = %d\n', totallen);
            sOutput.endRun();
            curve.x = x(:,1:totallen);
            curve.s = s;
            
            global cds
            cds.options = contmrg( contset , session.optioninterface);
            
            curve.saveGlobalVars(session.getCurveType());
            session.getCurveManager().save(curve);
            session.notify('stateChanged');
            session.unlock();
            
            
            
        end
        
    end
    
    methods(Static)
        function computeForward(session)
            
            try
                global sOutput
                
                
                branch = session.getBranchManager().getCurrentBranch();
                if ~isempty(branch) && branch.callRedirect()
                    branch.call(session, 'forward');
                    
                elseif strcmp(session.getCurveType().getLabel() , 'O')
                    session.starterdata.setTrajectOptions();
                    cm = ContinuerManager();
                    sOutput = SessionOutput(session );
                    cm.orbit(session, OrbitPlotDispatch());
                else
                    cm = ContinuerManager();
                    %sOutput = SessionOutput(session );
                    cm.cont(session , 1); %FORWARD
                end
            catch err
                processError(err);
                session.unlock();
            end
        end
        
        function computeBackward(session)
            try
                global sOutput
                
                branch = session.getBranchManager().getCurrentBranch();
                if ~isempty(branch) && branch.callRedirect()
                    branch.call(session, 'backward');
                    return;
                end
                
                if strcmp(session.getCurveType().getLabel() , 'O')
                    errordlg('Backward iteration is not supported', 'Operation not supported')
                    return; 
                end

                cm = ContinuerManager();
                %sOutput = SessionOutput(session );
                cm.cont(session , 0); %BACKWARD
            catch err
                processError(err);
                session.unlock();                
            end
        end
        
        function computeExtend(session)
            try
                global sOutput
                branch = session.getBranchManager().getCurrentBranch();
                if ~isempty(branch) && branch.callRedirect()
                    branch.call(session, 'extend');          
                
                elseif strcmp(session.getCurveType().getLabel() , 'O')
                    session.starterdata.setTrajectOptions();
                    cm = ContinuerManager();
                    sOutput = SessionOutput(session );
                    cm.orbit_extend(session, OrbitPlotDispatch());                
                else
                    cm = ContinuerManager();
                    sOutput = SessionOutput(session);
                    cm.cont_extend( session );
                end
            catch err
                processError(err);
                session.unlock();                  
            end
        end
        %%%%%%%%%%%

        

    end
    

end

function processError(err)
    warning on;
    warning(err.getReport());
    errordlg('A fatal error occured during computation (see MATLAB Command Window)'); 
end


function X = evalf(fhandle , iter , X , param)
    for i = 1:iter
       X = feval(fhandle,0, X , param{:}); 
    end
end



