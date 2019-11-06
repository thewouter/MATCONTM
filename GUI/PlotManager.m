classdef PlotManager < handle
    properties
        plotlist;
        cfgstack = { };
    end
    properties(Constant)
        STACKSIZE = 6;
    end
    events
        stackChanged
    end
    methods
        
        function obj = PlotManager(session)
            
            obj.plotlist = {};
            session.addlistener('newSystem' , @(o,e) systemChanged(obj,session));
        end
        
        function createPlot(obj,session , dim)
            
            fig = figure();
            
            cfg = obj.popCfg(dim);
            
            if (isempty(cfg))
                pc = PlotConfiguration(session,fig , dim);
            else
                pc = PlotConfiguration.constructPlotConfiguration(session, fig , cfg);
                
            end
            PlotConfiguration.installMenu(fig , pc , session);
            obj.plotlist{end+1} = pc;
            
        end
        
        function create2Dplot(obj,session)
            obj.createPlot(session , 2);
        end
        function create3Dplot(obj,session)
            obj.createPlot(session , 3);
        end
        
        
        function createMultPlot(obj, session)
            fig = figure();
            pc = PlotMult(obj , fig,session);
            obj.plotlist{end+1} = pc;
        end
        
        
        
        
        function systemChanged(obj,session)
            
            for i = 1:length(obj.plotlist)
                obj.plotlist{i}.destructor();
            end
            
            obj.plotlist = {};
            obj.cfgstack = {};
        end
        
        
        function list = preparePlotList(obj)
            list={};
            for i = 1:length(obj.plotlist)
                if (obj.plotlist{i}.checkLayoutValid())
                    list{end+1} = obj.plotlist{i}.makeReadyPlotObject();
                end
            end
        end
        
        function A = saveobj(obj)
            A.list = {};
            A.pos = {};
            for i = length(obj.plotlist):-1:1
                if (obj.plotlist{i}.isAlive() &&  obj.plotlist{i}.checkLayoutValid()) %FIXME: eventueel invalid toelaten
                    A.list{end+1} = obj.plotlist{i}.saveobj();
                    A.pos{end+1} = get(obj.plotlist{i}.getFigure(),'Position');
                end
                
            end
        end
        
        function loadIn(obj,session,data)
            for i = 1:length(data.list)
                fig = figure( 'Position' , data.pos{i} );
                obj.plotlist{i} = PlotConfiguration.constructPlotConfiguration(session, fig , data.list{i});
                PlotConfiguration.installMenu(fig , obj.plotlist{i} , session);
            end
        end
        
        function destructor(obj)
            for i = length(obj.plotlist):-1:1
                obj.plotlist{i}.destructor();
            end
            
            delete(obj);
        end
        
        
        function reportShutdown(obj , plotconf)
            obj.removeFromList(plotconf);
            obj.pushCfg(plotconf.saveobj());
            plotconf.destructor();
        end
        
        function removeFromList(obj , plotconf)
            
            for i = length(obj.plotlist):-1:1
                if(plotconf.eq(obj.plotlist{i})) %handle equality
                    obj.plotlist(i)  = [];
                    return
                end
            end
        end
        
        function pushCfg(obj , A)
            obj.cfgstack{end+1} = A;
            len = length(obj.cfgstack);
            if (len > obj.STACKSIZE)
                %obj.cfgstack{dim}(1:(len - obj.STACKSIZE)) = [];
                obj.cfgstack(1) = [];
            end
            obj.notify('stackChanged');
            
        end
        
        function A = popCfg(obj , dimension)
            A = [];
            for i = length(obj.cfgstack):-1:1
                if (obj.cfgstack{i}.dim == dimension)
                    A = obj.cfgstack{i};
                    obj.cfgstack(i) = [];
                    obj.notify('stackChanged');
                    return;
                end
            end
        end
        
        function len = getCfgStackSize(obj)
            len = length(obj.cfgstack);
        end
        
        function selectCfg(obj, session , index)
            cfg = obj.cfgstack{index};
            obj.cfgstack(index) = [];
            fig = figure();
            pc = PlotConfiguration.constructPlotConfiguration(session, fig , cfg);
            PlotConfiguration.installMenu(fig , pc , session);
            obj.plotlist{end+1} = pc;
            obj.notify('stackChanged');
            
        end
        
        function str = getCfgStr(obj , index)
            cfg = obj.cfgstack{index};
            str = [num2str(cfg.dim) 'D:'];
            for i = 1:cfg.dim
                str = [str '  ' cfg.configstruct{i}.selection.label '('   sprintf('%g' , cfg.configstruct{i}.region(1)) ', ' sprintf('%g' , cfg.configstruct{i}.region(2)) ')'];
            end
        end
        
    end
    
    
end

