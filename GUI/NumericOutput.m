classdef NumericOutput
    %NUMERICOUTPUT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        setterlist = struct();
    end
    
    methods
        function obj = NumericOutput(numeric, session)
            
            system    = session.getSystem();
            startdata = session.getStartData();
            coords    = system.getCoordinateList();
            params    = system.getParameterList();
            
            
            %XOUT
            for i = 1:length(coords)
                handle = numeric.getHandle('coordinates', coords{i});
                set ( handle , 'String' , num2str( startdata.getCoordinate(coords{i}) ,'%0.8g'));
                obj.setterlist.xout{i} = @(val) set ( handle , 'String' , num2str(val ,'%0.8g'));
            end
		
            
            
            %XOUT-param
            curveLabel = session.getCurveType().getLabel();
            if (ismember(curveLabel , {'HE' , 'HO' , 'HetT' , 'HomT' }))
                
                
                nr_of_extra_points = length(startdata.manifolddata.conorbit.getPoints(curveLabel)) - 1;
                dim = length(coords);
                for i = 1:(nr_of_extra_points * dim)
                    obj.setterlist.xout{end+1} = @(val) 0; %kan beter.
                end

                riclen = NumericOutput.riccatiDataLength(curveLabel);
                
                for j = 1:riclen
                    obj.setterlist.xout{end+1} = @(val) 0;  %% YU , YS
                end
            end
            for i = 1:length(params)
                handle = numeric.getHandle('parameters', params{i});
                set(handle , 'String' ,  num2str(startdata.getParameter(params{i}) , '%0.8g'));
                if (startdata.getFreeParameter(params{i}))
                    obj.setterlist.xout{end+1} =   @(val) set ( handle , 'String' , num2str(val ,'%0.8g'));
                end
            end
            
            
            
            %%%%
            %HOUT
	    handle = numeric.getHandle('current_stepsize');
            obj.setterlist.hout{1} = @(val) set( handle , 'String' , num2str(val ,'%0.8g'));
            obj.setterlist.hout{2} = @(val) 0;  %not USED in numeric window
            
            %userfunctions
            
            if (startdata.userfunctionsEnabled())
                ufnr = startdata.getNrUserfunctions();
                for i = 1:ufnr
                    if (startdata.isValidUserfunction(i))
                        
                        if (startdata.isEnabledUserfunction(i))
                            ufhandle = numeric.getHandle('user_functions' , startdata.getLabelUserfunction(i));
                            %disp(ufhandle);
                            obj.setterlist.hout{end+1} = @(val) set ( ufhandle , 'String' , num2str(val ,'%0.8g'));
                        else
                            obj.setterlist.hout{end+1} = @(val) 0;
                        end
                    else
                        obj.setterlist.hout{end+1} = @(val) 0;
                    end
                    
                end
            end
            
            %singularities
            ignoresingularity = session.optioninterface.IgnoreSingularity; %optionstruct , list van singularities
            %calculate real ignoresingularity:
            if (strcmp(session.getCurveType().getLabel() , 'NS'))
                singMatrix = session.getCurveType().getSingMatrix();
                singMatrix(ignoresingularity , :) = [];
                realignoresingularity = find(~sum((8-singMatrix),1));
            else
                realignoresingularity = ignoresingularity ;
            end
            
            if (session.optioninterface.Singularities)
                list = numeric.getSubSections('testfunctions');  %%FIXME: enige gebruik van deze functie
                for i = 1:length(list)
                    if (ismember(i , realignoresingularity ))
                        %Ignore
                    else
                        if (ismember(i,ignoresingularity))
                            obj.setterlist.hout{end+1} =   @(val) 0; %pseudoignore
                        else
                            handle = numeric.getHandle('testfunctions' ,  list{i});
                            obj.setterlist.hout{end+1} =   @(val) set ( handle , 'String' , num2str(val ,'%0.8g'));
                        end
                    end
                end
            end
            
            %FOUT
            if(startdata.getMultipliers())
            for i = 1:length(coords)
                handle1 = numeric.getHandle('multipliers' , ['mod_' num2str(i)]);
                handle2 = numeric.getHandle('multipliers' , ['arg_' num2str(i)]);
                obj.setterlist.fout{i} = @(val) setMultiplier(handle1, handle2 , val);
            end
            else
               obj.setterlist.fout = {}; 
            end
            
            nhandle = numeric.getHandle('npoints');
            obj.setterlist.npoints = @(val) set( nhandle , 'String' , num2str(val ,'%0.8g'));
            
        end
        
        
        function output(obj,xout,s,hout,fout,ind)
            
            iter = ind(end);
            
            xout_len = size(xout,1);
            hout_len = size(hout,1);
            fout_len = size(fout,1);
            
            for i = 1:min(xout_len,length(obj.setterlist.xout))
                obj.setterlist.xout{i}( xout(i,iter) );
            end
            for i = 1:min(hout_len,length(obj.setterlist.hout))
                obj.setterlist.hout{i}( hout(i,iter) );
            end
            for i = 1:min(fout_len, length(obj.setterlist.fout))
                obj.setterlist.fout{i}( fout(i,iter) );
            end
            obj.setterlist.npoints(iter);
            
        end
        
    end
    methods(Static)
        
        function [len] = riccatiDataLength(curvelabel)
            global hetds homds;
            switch(curvelabel)
                case 'HE'
                    ds = hetds;
                case 'HO'
                    ds = homds;
                case 'HetT'
                    ds = hetds;
                    
                case 'HomT'
                    ds = homds;
                otherwise
		    ds.riccativectorlength = 0;
            end
            len = ds.riccativectorlength;
            
        end
        
    end
    
end


function setMultiplier(handlemod, handlearg , val)
    set(handlemod, 'String' , num2str(abs(val) ,'%0.8g'));
    set(handlearg, 'String' , num2str((180/pi)*angle(val) ,'%0.8g'));
end




