classdef PlotConfigSelection < handle
    %PLOTCONFIGSELECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       options
       type
       %%%%%%%%%%%%%%%%%%%%%%%%
       init_call
       retrieveSelection_call
       retrieveLabel_call
       checkValidity_call
       %%%%%%%%%%%%%%%%%%%%%%%
       
       listID;
       
       updateFcn = @() 0;
       
    end
    
    properties(Constant)
       NOTHING = -1;       
       COORDINATES = 1;
       PARAMETERS = 2;
       MULTIPLIERS = 3;
       USERFUNCTIONS = 4;
       TESTFUNCTIONS = 5;
       ITERATION = 6;
    end
    
    methods
        function obj = PlotConfigSelection(type , listID,  updateFcn   , optiondata)

            if (nargin == 3)
                obj.options = struct();
            else
                obj.options = optiondata;
            end
            obj.configure(type);
            obj.listID = listID;
	    obj.updateFcn = updateFcn;

        end
        function t = getType(obj)
           t = obj.type ;
        end
        function setUpdateFcn(obj , fcn)
            obj.updateFcn = fcn;
        end
        function updateGraph(obj)
           obj.updateFcn(); 
        end
        
        
        function configure(obj,type)
           obj.type = type;
           switch(type)
               case  PlotConfigSelection.COORDINATES
                   obj.init_call              = @init_coord;
                   obj.retrieveSelection_call = @retrieveSelection_coord;
                   obj.retrieveLabel_call     = @retrieveLabel_coord;
                   obj.checkValidity_call     = @(a,b,c) true;
                   %
               case  PlotConfigSelection.PARAMETERS
                   obj.init_call              = @init_param;
                   obj.retrieveSelection_call = @retrieveSelection_param;
                   obj.retrieveLabel_call     = @retrieveLabel_param;      
                   obj.checkValidity_call     = @(a,b,c) true;
               case  PlotConfigSelection.MULTIPLIERS
                   obj.init_call              = @init_multipliers;
                   obj.retrieveSelection_call = @retrieveSelection_multipliers;
                   obj.retrieveLabel_call     = @retrieveLabel_multipliers;      
                   obj.checkValidity_call     = @checkValidity_multipliers;
               case  PlotConfigSelection.TESTFUNCTIONS
                   obj.init_call              = @init_testfunctions;
                   obj.retrieveSelection_call = @retrieveSelection_testfunctions;
                   obj.retrieveLabel_call     = @retrieveLabel_testfunctions;      
                   obj.checkValidity_call     = @checkValidity_testfunctions; 
               case  PlotConfigSelection.USERFUNCTIONS
                   obj.init_call              = @init_userfunctions;
                   obj.retrieveSelection_call = @retrieveSelection_userfunctions;
                   obj.retrieveLabel_call     = @retrieveLabel_userfunctions;      
                   obj.checkValidity_call     = @checkValidity_userfunctions;  
               case  PlotConfigSelection.ITERATION
                   obj.init_call              = @(a,b,c,d) 0;
                   obj.retrieveSelection_call = @(a,b) (@(xout, hout, fout, it) it);
                   obj.retrieveLabel_call     = @(a,b) 'Iter';   
                   obj.checkValidity_call     = @(a,b) true;                     

               otherwise
                   obj.init_call              = @(o,p,l,s) 0;
                   obj.retrieveSelection_call = @(o,s) (@(x,h,f,i) -1);
                   obj.retrieveLabel_call     = @(o,s) '*';    
                   obj.checkValidity_call     = @(a,b) false;
           end
            
        end
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function id = getListID(obj)
            id = obj.listID;
        end
        
        function init(obj , parent, layoutnode, session)
            feval(obj.init_call, obj , parent, layoutnode, session);
        end
        function funchandle = retrieveSelection(obj, varargin)
           funchandle = feval(obj.retrieveSelection_call, obj, varargin{:});
        end
        function lblstr = retrieveLabel(obj,session)
           lblstr = feval(obj.retrieveLabel_call, obj, session);
        end
        function bool = checkValidity(obj,varargin)
           bool = feval(obj.checkValidity_call, obj, varargin{:}); 
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function init_coord(obj, parent , layoutnode,session)
            if(~isfield(obj.options,'value'))
                obj.options.value = 1;
            end
            
            obj.options.popuphandle = uicontrol(parent, 'Style' , 'popupmenu' , 'String' , session.getSystem().getCoordinateList(),'Value' , obj.options.value, 'Callback' , @(o,e) obj.popupCallback(o,e));
            layoutnode.addHandle(1,1, obj.options.popuphandle,'minsize',[120 0]);
        end
        
        function funchandle = retrieveSelection_coord(obj, session , curve)
            index = obj.options.value;
            assert(index > 0);
            if (nargin < 3)
                ctlbl = session.getCurveType().getLabel();
            else
                ctlbl = curve.getCurveType().getLabel();
            end
            if ismember(ctlbl, {'IC'}) 
                funchandle = @(xout, hout, fout, it) [xout(:,it); index];
            else
                funchandle = @(xout, hout, fout, it) xout(index,it);
            end
            
        end
        
        function lblstr = retrieveLabel_coord(obj,session)
            
            lblstr = session.getSystem().getCoordinateByIndex(obj.options.value);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function init_param(obj, parent , layoutnode,session)
            if(~isfield(obj.options,'value'))
                obj.options.value = 1;
            end
            obj.options.popuphandle = uicontrol(parent, 'Style' , 'popupmenu' , 'String' , session.getSystem().getParameterList(),'Value' , obj.options.value, 'Callback' , @(o,e) obj.popupCallback(o,e));
            layoutnode.addHandle(1,1, obj.options.popuphandle,'minsize',[120 0]);
        end
        function funchandle = retrieveSelection_param(obj, session , curve)
            if (nargin < 3)
                startdata = session.getStartData();
                ctlbl = session.getCurveType().getLabel();
            else
                startdata = curve.getStartData(session.system);
                ctlbl = curve.getCurveType().getLabel();
            end
            
            index = obj.options.value;
            assert(index > 0);
            
            if (startdata.isFreeParamsByIndex(index))
                xout_index = session.getSystem().getNrCoordinates();
                

                if (ismember(ctlbl , {'HE' , 'HO' , 'HetT' , 'HomT' }) && ~isempty(startdata.manifolddata))
                    dim = xout_index;
                    
                    if (nargin < 3)
                        curve = session.getCurrentCurve();
                    end
                    
                    nr_of_extra_points = curve.getNrPoints() - 1;
                    riclen = curve.getRiccatiLength();
                    xout_index = xout_index +   (dim  *  nr_of_extra_points) + riclen;
                elseif ismember(ctlbl, {'IC'})
                    
                    if (nargin < 3)
                        NN = session.starterdata.settings.fourierModes;
                        dim = numel(session.system.coordinatelist);
                    else
                        dim = xout_index;
                        length = size(curve.x, 1);
                        NN = ((length - 1)/ xout_index -1 )/2;
                    end
                    xout_index = dim  + 2 * NN * dim - 1;
                end
                
                
                for i = 1:index
                    if (startdata.isFreeParamsByIndex(i))
                        xout_index = xout_index + 1;
                    end
                end
                funchandle = @(xout, hout, fout, it) xout(xout_index,it);
            else
                vals = startdata.getParameterValues();
                funchandle = @(xout,hout,fout,it)  vals(index);
            end
        end
        function lblstr = retrieveLabel_param(obj,session)
            
            lblstr = session.getSystem().getParameterByIndex(obj.options.value);
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function popupCallback(obj,handle , event)
           obj.options.value = get(handle,'Value'); 
           obj.updateGraph();
        end
        function popupTypeCallback(obj,handle , event)
           obj.options.type = get(handle,'Value');
           obj.updateGraph();

        end     
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function init_multipliers(obj,parent, layout , session)
           %IF Multipliers calculated;
            if(~ isfield(obj.options,'value'))
                obj.options.value = 1;
                obj.options.type = 1;
            end
            len = session.getSystem().getNrCoordinates();
            strings = cell(1, len);
            for i = 1:len
               strings{i} = ['#' num2str(i)]; 
            end
            if (session.getStartData().getMultipliers())
                layout.addHandle(1,1,uicontrol(parent, 'Style' , 'popupmenu' , ... 
                'String' , strings ,'Value' , obj.options.value, 'Callback' , @(o,e) obj.popupCallback(o,e)),'minsize' , [120 0]);   
            
                layout.addHandle(1,1,uicontrol(parent, 'Style' , 'popupmenu' , ... 
                'String' , {'Modulus', 'Real part' , 'Imaginairy part' } ,'Value' , obj.options.type, 'Callback' , @(o,e) obj.popupTypeCallback(o,e)),'minsize' , [120 0]);
            end
        end
        function lblstr = retrieveLabel_multipliers(obj,session)
               switch (obj.options.type)
                   case 1
                       lblstr = ['Abs[' num2str(obj.options.value) ']'];
                   case 2
                       lblstr = ['Re[' num2str(obj.options.value) ']'];
                   otherwise
                       lblstr = ['Im[' num2str(obj.options.value) ']'];
                       
               end
        end  
        function funchandle = retrieveSelection_multipliers(obj, session , curve)
       
            val = obj.options.value;
            switch(obj.options.type)
                case 1
                    funchandle = @(xout, hout, fout, it) abs(fout(val,it)); 
                case 2
                    funchandle = @(xout, hout, fout, it) real(fout(val,it));
                otherwise
                    funchandle = @(xout, hout, fout, it) imag(fout(val,it));
            end
        end
        function bool = checkValidity_multipliers(obj,session,curve )
            if (nargin < 3)
                startdata = session.getStartData();
            else
                startdata = curve.getStartData(session.system);
            end
            bool = startdata.getMultipliers();
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function init_testfunctions(obj,parent, layout , session)
            
            if(~ isfield(obj.options,'value'))
                obj.options.value = 1;
                obj.options.type = 2;          
                startdata = session.getStartData();
                singlist = startdata.getSingularitiesList();
                for i = length(singlist):-1:1
                   if (~startdata.getMonitorSingularities(singlist{i})) 
                        singlist(i) = [];
                   end
                end
                obj.options.singlist = singlist;
                obj.options.cttag = session.getCurveType().getLabel();
            end
            if (~isempty(obj.options.singlist))
		    layout.addHandle(1,1,uicontrol(parent, 'Style' , 'popupmenu' , ... 
                'String' , obj.options.singlist  ,'Value' , obj.options.value, 'Callback' , @(o,e) obj.popupCallback(o,e)),'minsize' , [120 0]);            
            end
        end
        
        function lblstr = retrieveLabel_testfunctions(obj,session)
%                switch (obj.options.type)     
%                end
                lblstr = obj.options.singlist{ obj.options.value };
        end   
        
        function bool = checkValidity_testfunctions(obj,session , curve)
            if (nargin < 3)
                startdata = session.getStartData();
                curvetype = session.getCurveType();
            else
                startdata = curve.getStartData(session.system);
                curvetype = curve.getCurveType();
            end
            
            bool = strcmp(curvetype.getLabel() , obj.options.cttag) && startdata.getMonitorSingularities(obj.options.singlist{ obj.options.value });
        end 
        
        function funchandle = retrieveSelection_testfunctions(obj, session , curve)
            if (nargin < 3)
                startdata = session.getStartData();
                curvetype = session.getCurveType();
            else
                startdata = curve.getStartData(session.system);
                curvetype = curve.getCurveType();
            end
            ignoresingularity = ContinuerOptionInterface.getIgnoreSingularity(startdata);
            
            if (strcmp(curvetype.getLabel() , 'NS'))
                singMatrix = curvetype.getSingMatrix();
                singMatrix(ignoresingularity , :) = [];
                realignoresingularity = find(~sum((8-singMatrix),1));
            else
                realignoresingularity = ignoresingularity ;
            end
            

            singlist =  startdata.getSingularitiesList();
            selectedtest = obj.options.singlist{ obj.options.value };
            index_hout = 3;
            
            if (startdata.userfunctionsEnabled())
                index_hout = index_hout + startdata.getNrUserfunctions();
            end
            
            len = length(singlist);
            i = 1;
            
            while ((i <= len) && (~strcmp(singlist{i} , selectedtest)))
                if (ismember(i , realignoresingularity ))
                    %Ignore
                else
                    index_hout = index_hout + 1;
                end
                i = i + 1;
            end
            
           
            funchandle = @(xout, hout, fout, it) hout(index_hout,it);

          
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
function  setIndex(obj , index)
    obj.options.value = index;
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function init_userfunctions(obj,parent, layout , session)
            if(~ isfield(obj.options,'value'))
                obj.options.value = 1;
                obj.options.type = 2;          
                startdata = session.getStartData();
                %%%
                
                uflist = {};
                
                ufnr = startdata.getNrUserfunctions();
                
                for i = 1:ufnr
                   if (startdata.isEnabledUserfunction(i))
                    uflist{end+1} = startdata.getLabelUserfunction(i);
                   end
                end
                
                obj.options.uflist = uflist;
            end
            if (~isempty(obj.options.uflist))
                layout.addHandle(1,1,uicontrol(parent, 'Style' , 'popupmenu' , ... 
                    'String' , obj.options.uflist  ,'Value' , obj.options.value, 'Callback' , @(o,e) obj.popupCallback(o,e)),'minsize' , [120 0]);   
  
            end
	    end
        function lblstr = retrieveLabel_userfunctions(obj,session)
               lblstr = obj.options.uflist{ obj.options.value };
        end
        
        function bool = checkValidity_userfunctions(obj,session , curve)
            if (nargin < 3)
                startdata = session.getStartData();
            else
                startdata = curve.getStartData(session.system);
            end
             
             i = startdata.getUserFunctionIndex( obj.options.uflist{ obj.options.value }  );
             bool = startdata.isEnabledUserfunction(i);
        end
        
        function funchandle = retrieveSelection_userfunctions(obj, session , curve)
            if (nargin < 3)
                startdata = session.getStartData();
            else
                startdata = curve.getStartData(session.system);
            end
             i = startdata.getUserFunctionIndex( obj.options.uflist{ obj.options.value }  );
             index_hout = 2 + i;
             
            funchandle = @(xout, hout, fout, it) real(hout(index_hout,it));

                      
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function A = saveobj(obj)
        A.type = obj.type;
        A.listID = obj.listID;
        A.options = obj.options;
    end




    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end
    
    methods(Static)
        function obj = constructPCSelection(data)
            obj = PlotConfigSelection(data.type , data.listID, @()0 , data.options);
        end
          
        
    end
end
    
