classdef BranchManager < handle
    %BRANCHMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        branchlist
        selection
        
    end
    
    properties(Constant)
        DF = DefaultCurve();
        
    end
    
    events
        newlist
        selectionChanged
    end
    
    
    methods
        
        function obj = BranchManager(session)
            obj.clean();
            
            if (nargin > 0)
                session.addlistener('newSystem' , @(o,e) obj.clean());
            end
            
        end
        
        function setup(obj, session)
            pointtype = session.getPointType().getLabel();
            
            
            obj.selection = -1;
            clist = CurveType.getList();
            
            printc(mfilename, ['pointtype is ' pointtype]);
            
            obj.branchlist = {};
            
            curveInitLabel = session.getCurrentCurve().getInitLabel();
            
            if(isempty(curveInitLabel))
                printc(mfilename, 'default from defaultlist');
                parrentcurvetype = session.getCurrentCurve().getParentCT(); %may be empty string
                defaultbranchlabel = obj.DF.retrieveDefaultCurve(pointtype, parrentcurvetype);
            else
                printc(mfilename, 'default from curve');
                defaultbranchlabel = curveInitLabel;
            end
            printc(mfilename , ['default init: ' defaultbranchlabel ]);
            
            
            for i = 1:length(clist)
                obj.branchlist = [ obj.branchlist  clist{i}.getBranches( pointtype , session )];
            end
            
            
            if (~strcmp(defaultbranchlabel , obj.DF.NOTHING))
                i = 1;
                blen = length(obj.branchlist);  %can be zero
                
                while ((i <= blen) && (~strcmp(defaultbranchlabel, obj.branchlist{i}.getLabel())))
                    i  = i+1;
                end
                
                if ( i <= blen)
                    printc(mfilename , ['branch found: ' obj.branchlist{i}.toString() ]);
                    obj.select(session, i);
                end
            end
            obj.notify('newlist');
            session.notify('stateChanged');
        end
        
        
        function clean(obj)
            obj.selection = -1;
            obj.branchlist = {};
            obj.notify('newlist');
            obj.notify('selectionChanged');
        end
        function nr = getNr(obj)
            nr = length(obj.branchlist);
        end
        function list = getList(obj)
            list = obj.branchlist;
        end
        
        function select(obj,session,index)
            obj.selection = index;
            b = obj.getCurrentBranch();
            
            if (~isempty(b))
                starter =  session.getStartData();
                session.setCurveType( b.getCurveType() );
                
                amp_enabled = strcmp(b.getType(),'SH') || strcmp(b.getType(),'eps');
                printc(mfilename, 'setting amplitude enabled: %d' , amp_enabled);
                
                starter.setEnabled('amplitude' , amp_enabled);
                starter.notify('structureChanged');
                
                session.notify('stateChanged');
                obj.notify('selectionChanged');
            end
        end
        function i = getSelectionIndex(obj)
            i = obj.selection;
        end
        function bool = validSelectionMade(obj)
            bool =  ((obj.selection >= 1) &&  (obj.selection <= obj.getNr()));
        end
        
        function b = getCurrentBranch(obj)
            if((obj.selection >= 1) &&  (obj.selection <= obj.getNr()))
                b =  obj.branchlist{ obj.selection };
            else
                b =  [];
            end
        end
        
        function initlabel = getCurrentBranchLabel(obj)
            initlabel = obj.branchlist{ obj.selection }.getLabel();
        end
        
        function str = getCurrentInfo(obj)
            if((obj.selection >= 1) &&  (obj.selection <= obj.getNr()))
                b =  obj.branchlist{ obj.selection };
                str = b.toString();
            else
                str =  '';
            end
            
        end
        
        function inm = getMultiplyIterationN(obj)
            b = obj.getCurrentBranch();
            inm = b.getPeriodMult();
        end
        
        
        function [x0,v0] = performInit(obj,session , curve, coord , par , systemhandle , n)
            branch = getCurrentBranch(obj);
            x0 = [];
            v0 = [];
            if (isempty(branch))
                errordlg('no curve selected' , 'error');
                return;
            end
            
            ap = session.starterdata.getActiveParams(); %IDs of active params?
            
            switch (branch.getType)
                case 'D'
                    [x0,v0] = callInit(branch, systemhandle, coord, par, ap, n);
                case 'eps'
                    amplitude_eps = session.starterdata.getSetting('amplitude')
                    [x0,v0] = callInit(branch, systemhandle, amplitude_eps, coord, par, ap, n);
                case 'IC'
                    NN = session.starterdata.getSetting('fourierModes');
                    amp = session.starterdata.getSetting('epsilon');
                    [x0,v0] = callInit(branch, systemhandle, coord, par, NN, amp, ap, n);
                case 'DS'
                    if (isempty(curve.startpoint) || (~ isfield(curve.startpoint.data, 'kappa')) )
                        errordlg(['init failed! Missing data for '  branch.getLabel() '. Initial point probably needs to be detected on a curve first.']);
                        return;
                    end                    
                    [x0,v0] = callInit(branch, systemhandle, coord, par, ap, curve.startpoint.data.kappa ,  n);
                case 'SH'
                    if isempty(curve.startpoint)
                        errordlg(['init failed! Missing data for '  branch.getLabel() '. Initial point probably needs to be detected on a curve first.']);
                        return;
                    end
                    
                    label = branch.getLabel();
                    switch(label)
                        case 'init_PDm_FP2m'
                            if ((~ isfield(curve.startpoint.data, 'q')) || (isempty(curve.startpoint.data.q)))
                                errordlg(['init_PDm_FP2m failed: eigenvector data is missing. Try redetecting the PD-point on a FP-curve']);
                                return;
                            end
                        case  'init_BPm_FPm'
                            if ((~ isfield(curve.startpoint.data, 'v')) || (isempty(curve.startpoint.data.v)))
                                errordlg(['init_BPm_FPm failed: tangent of new branch is missing. Try redetecting the BP-point on a FP-curve']);
                                return;
                            end
                        otherwise
                    end
                    
                    
                    amplitude_h =  session.starterdata.getSetting('amplitude');
                    [x0,v0] = callInit(branch, systemhandle, coord, par, curve.startpoint, amplitude_h, n);
                    
                case 'HCO'
                    orbitdata  = session.starterdata.manifolddata.conorbit;
                    if (isempty(orbitdata))
                        errordlg('No connecting orbit selected for continuation');
                        return;
                    end
                    
                    label = session.getCurveType().getLabel(); 
                    
                    points = orbitdata.getPoints(label);
                    
                    [x0 , v0] = callInit(branch, systemhandle, points , par , ap ,  n);
                    
                case 'HCT'
                    orbitdata  = session.starterdata.manifolddata.conorbit;
                    if (isempty(orbitdata))
                        errordlg('No connecting orbit selected for continuation');
                        return;
                    end
                    label = session.getCurveType().getLabel(); 
                    points = orbitdata.getPoints(label);
                    
                    if (isempty(curve.startpoint))
                        errordlg(['init failed! Missing data for '  branch.getLabel() '. Initial point probably needs to be detected on a curve first.']);
                        return;
                    end
                    if ( isfield(curve.startpoint.data , 'NU') && isfield(curve.startpoint.data , 'NS'))
                        
                        C = [points(:) ; curve.startpoint.data.riccatidata];
                        [x0 , v0] = callInit(branch, systemhandle, C , length(coord) ,curve.startpoint.data.NU ,  curve.startpoint.data.NS , par  , ap ,  n);
                    else
                        errordlg(['init failed! Missing data for '  branch.getLabel() '. Initial point probably needs to be detected on a curve first.']);
                    end
                    
                otherwise
                    error('otherwise happended');
            end
            
        end
        
        
        
    end
end

function [x0,v0] = callInit(branch, varargin)
init = branch.getInitFunc();
printc(mfilename , ['Call ' func2str(init) '  ']); %disp(varargin);

if (branch.isConditional())
    global initmsg;
    initmsg = '';
    [x0,v0] = init(varargin{:});
    
    if (isempty(x0))
        errordlg([branch.toString(), char(10), initmsg], 'condition failed');
    end
else
    [x0,v0] = init(varargin{:});
    if (isempty(x0))
        errordlg('Init failed');
    end
end
end
