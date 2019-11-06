function varargout = userfun(varargin)
% USERFUN Application M-file for userfun.fig
%    FIG = USERFUN launch userfun GUI.
%    USERFUN('callback_name', ...) invoke the named callback.


% Last Modified by GUIDE v2.0 04-Sep-2002 11:20:31
global  system 
if nargin == 0  % LAUNCH GUI

	system.struct.forbiddentags = {'FP' , 'NS' , 'LP' , 'PD' , 'CP', 'CH' , 'R1' , 'R2' , 'R3','R4' , 'BP' };
	
	fig = openfig(mfilename,'reuse');
    system.old_struct = system.struct;
	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
    load_listbox1(handles);
	
	
	% Wait for callbacks to run and window to be dismissed:
	uiwait(fig);

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);      
	end
end

% --------------------------------------------------------------------
function adbutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.adbutton.

global system;
label = get(handles.label,'String');
name  = get(handles.name,'String');
if length(label)>2
    warndlg('A label exist of 2 characters')
    set(handles.label,'String',label(1:2));
elseif length(label)<2
    while length(label)<2
        label = sprintf('%s%c',label,char(32));
    end
    set(handles.label,'String',label(1:2));
end
if length(name)<1
    warndlg('You have to enter the name of the function');
    return;
end
if isfield(system.struct,'userfunction')%userfunctions already exists
    dim = size(system.struct.userfunction,2);
    namestr  = cellstr(char(system.struct.uf.UserfunctionsInfo.name));
    labelstr = cellstr(char(system.struct.uf.UserfunctionsInfo.label));
    system.struct.uf.UserfunctionsInfo(dim+1).label = label;
    system.struct.uf.UserfunctionsInfo(dim+1).name = name;
    system.struct.uf.UserfunctionsInfo(dim+1).state = 1;
    system.struct.userfunction{dim+1} = get(handles.edituserfunction,'String');
    i = find(strcmp(namestr,name));
    if i
        button = questdlg('Userfunction already exist! Do you want to continue? If you press yes to continue, you will overwrite the existing userfunction',...
            'Userfunction already exist','Yes','No','No');
        if strcmp(button,'No')
            system.struct.userfunction(dim+1) = [];
            system.struct.uf.UserfunctionsInfo(dim+1) = [];
            return;
        elseif strcmp(button,'Yes')
            system.struct.userfunction(dim+1)=[];
            system.struct.uf.UserfunctionsInfo(dim+1) = [];
            system.struct.uf.UserfunctionsInfo(i).label = label;
            system.struct.uf.UserfunctionsInfo(i).name = name;
            system.struct.userfunction{i} = get(handles.edituserfunction,'String');
        end
    end
    if find(strcmp(labelstr,label))
        warndlg('There is another userfunction using this label: please choose another label!');
        set(handles.label,'String','');
        system.struct.userfunction(dim+1) = [];
        system.struct.uf.UserfunctionsInfo(dim+1) = [];
    end
else
    system.struct.uf.UserfunctionsInfo=[];
    system.struct.userfunction{1}=get(handles.edituserfunction,'String');
    system.struct.uf.UserfunctionsInfo.label = label;
    system.struct.uf.UserfunctionsInfo.name  = name;
    system.struct.uf.UserfunctionsInfo.state = 1;
end
load_listbox1(handles);

  
% --------------------------------------------------------------------
function listbox1_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.renamebutton.
global system
if isfield(system.struct,'userfunction')
    val=get(handles.listbox1,'Value');
    d=0;
    for k=1:size(system.struct.userfunction,2)
        if ~isempty(system.struct.userfunction{k})
            d=d+1;
            if d==val
                set(handles.name,'String',system.struct.uf.UserfunctionsInfo(k).name);
                name_Callback(handles,[],handles);
                set(handles.label,'String',system.struct.uf.UserfunctionsInfo(k).label);
                set(handles.edituserfunction,'String',system.struct.userfunction{k});
                break;
            end
        end
    end
else
    set(handles.name,'String','');
    name_Callback(handles,[],handles);
    set(handles.label,'String','');
    set(handles.edituserfunction,'String','');
end


% --------------------------------------------------------------------
function label_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.renamebutton.
global system
label=get(handles.label,'String');
if length(label)>2
    warndlg('A label exist of 2 characters')
    set(handles.label,'String',label(1:2));
elseif length(label)<2
    while length(label)<2
        label=sprintf('%s%c',label,char(32));
    end
    set(handles.label,'String',label(1:2));
end

if ismember(label , system.struct.forbiddentags );
    warndlg('Labels should be unique and differ from labels of standard special points.')
    set(handles.label,'String','');
end

% --------------------------------------------------------------------
function name_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.renamebutton.
global system
set(handles.adbutton,'Enable','on');
set(handles.updatebutton,'Enable','off');
name = get(handles.name,'String');
if isfield(system.struct,'userfunction')%userfunctions already exists
    if find(strcmp(cellstr(strvcat(system.struct.uf.UserfunctionsInfo.name)),name))
        set(handles.updatebutton,'Enable','on');
        set(handles.adbutton,'Enable','off');
    end
end


% --------------------------------------------------------------------
function deletebutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.deletebuttton.
global system
% set(handles.deletebutton,'Enable','off');

name  = get(handles.listbox1,'String');
val   = get(handles.listbox1,'Value');
label = get(handles.label,'String');
if isfield(system.struct,'userfunction')%userfunctions already exists
    dim = size(system.struct.userfunction,2);
    i = find(strcmp(cellstr(char(system.struct.uf.UserfunctionsInfo.name)),name{val}));
    if i
        button = questdlg('Do you want to continue? If you press yes to continue, you will delete the existing userfunction',...
                'Delete userfunction ','Yes','No','No');          
        if strcmp(button,'Yes')
            if isfield(system.struct,'poincare_eq') && ~isempty(system.struct.poincare_eq)
                funct=func2str(system.struct.poincare_eq);
                if strcmp(funct,name{val})
                    system.struct.poincare_eq=[];
                    system.struct.poincare_do=0;
                    system.struct=rmfield(system.struct,'poincare_eq');
                end
            end    
            system.struct.userfunction{i} = '';
            system.struct.uf.UserfunctionsInfo(i).state = 0;
        end
    end
end
load_listbox1(handles);

% --------------------------------------------------------------------
function updatebutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.updatebutton.
global system
nameu = get(handles.name,'String'); label = get(handles.label,'String');
if isfield(system.struct,'userfunction')%userfunctions already exists
    i = find(strcmp(cellstr(char(system.struct.uf.UserfunctionsInfo.name)),nameu));
    system.struct.uf.UserfunctionsInfo(i).label = label;
    system.struct.uf.UserfunctionsInfo(i).name = nameu;
    system.struct.uf.UserfunctionsInfo(i).state = 1;
    system.struct.userfunction{i}=get(handles.edituserfunction,'String');
end
load_listbox1(handles);

% --------------------------------------------------------------------
function cancelbutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.cancelbutton.
global system 
system.struct  = system.old_struct;


delete(handles.userfunfig);

%-----------------------------------------------------------------
function load_listbox1(handles)
global system
if isfield(system.struct,'userfunction') && ~isempty(char(system.struct.userfunction))
    str = [];d=0;
    for i=1:size(system.struct.userfunction,2)
        if ~isempty(system.struct.userfunction{i})
            d=d+1;
            str{d,1} = system.struct.uf.UserfunctionsInfo(i).name;
            val=i;
        end
    end
    set(handles.listbox1,'String',cellstr(str),'Value',d);
    set(handles.name,'String',system.struct.uf.UserfunctionsInfo(val).name);
    name_Callback(handles,[],handles);
    set(handles.label,'String',system.struct.uf.UserfunctionsInfo(val).label);
    set(handles.edituserfunction,'String',system.struct.userfunction{val});
else
    set(handles.listbox1,'String','');
    set(handles.name,'String','');
    name_Callback(handles,[],handles);
    set(handles.label,'String','');
    set(handles.edituserfunction,'String','res=');

end


% --------------------------------------------------------------------
function okbutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.okbutton.
global system 
name = get(handles.name,'String');
ad   = get(handles.adbutton,'Enable');
if ~isempty(name) && strcmp(ad,'on')
    adbutton_Callback(h,[],handles,[]);
end
updat = get(handles.updatebutton,'Enable');
if ~isempty(name) && strcmp (updat,'on')
    updatebutton_Callback(h,[],handles,[]);
end
if isfield(system.struct,'userfunction'),system.struct.uf.Userfunctions = 1;
else system.struct.uf.Userfunctions = 0;end
string_jac = '';string_jacp = '';string_hess = '';string_hessp = '';string_tensor3='';string_tensor4='';string_tensor5='';

dimp = size(system.struct.parameters,1);par='';pa='';
if ~isempty(dimp)
    par = cellstr((strcat(',',char(system.struct.parameters{:,1}))));
    par = strcat(par{:,1});
    pa  = par(2:end);
end
cor = '';
t = system.struct.time{1,1};
if (~isempty(system.struct.dim))
    cor = cellstr((strcat(',',char(system.struct.coordinates{:,1}))));
    cor = strcat(cor{:,1}); cor = cor(2:end);
end
if (~isempty(t))
    t=strcat(t,',');
else
    t='t,';
end
string_sys = cellstr(systems('replace_sys_input',system.struct.equations));
if strcmp(string_sys,'error')
    errordlg('The number of equations is not correct','Error');
    return
end
fwrite = strcat(system.struct.system,'.m');
fwrite = fullfile(system.path_sys,fwrite);
[fid_write,message] = fopen(fwrite,'w');
if fid_write==-1
    errordlg(message,'Error');
    return
end
fread = fullfile(system.path_sys,'standard.m');
[fid_read,message] = fopen(fread,'r');
if fid_read == -1
    errordlg(message,'Error');
    return
end


set(handles.userfunfig , 'Visible' , 'off');
drawnow;
string_handles={'out{1} = @init;';
                'out{2} = @fun_eval;';
                'out{3} = [];';
                'out{4} = [];';
                'out{5} = [];';
                'out{6} = [];';
                'out{7} = [];';
                'out{8} = [];';
                'out{9} = [];';
                'return;';};
string_init = cellstr(systems('make_init'));
if (system.struct.der(3,1)==1|system.struct.der(4,1)==1)
    str_init=string_init{2};
    str_handles1=string_handles{3};
    str_handles2=string_handles{4};
    str_on='''Jacobian'',handles(3)';str_off='''Jacobian'',[]';
    strp_on='''JacobianP'',handles(4)';strp_off='''JacobianP'',[]';
    if ~isempty(par)
        str_init=strrep(str_init,str_off,str_on);
    end
    str_handles1=strrep(str_handles1,'[]','@jacobian');
    string_handles{3,1}=str_handles1;
    str_handles2=strrep(str_handles2,'[]','@jacobianp');
    string_handles{4,1}=str_handles2;
    str_init=strrep(str_init,strp_off,strp_on);string_init{2,1}=str_init;
    string_jac=system.struct.jac;string_jacp=system.struct.jacp;
end
if (exist('sym')==2&& system.struct.der(4,1)==1)
    string_jac  = cellstr(systems('symjac',handles,system.struct.equations,cor,pa,10));
    string_jacp = cellstr(systems('symjac',handles,system.struct.equations,cor,pa,11));
end    
if system.struct.der(3,1)==1
    string_jac  = cellstr(systems('replace_jac_input',system.struct.jac));
    string_jacp = cellstr(systems('replace_jacp_input',system.struct.jacp));
end
if (system.struct.der(3,2)==1|system.struct.der(4,2)==1)
    str_init=string_init{2};
    str_handles1=string_handles{5};
    str_handles2=string_handles{6};
    str_on='''Hessians'',handles(5)';str_off='''Hessians'',[]';
    strp_on='''HessiansP'',handles(6)';strp_off='''HessiansP'',[]';
    if ~isempty(par)
    str_init=strrep(str_init,str_off,str_on);
    end
    str_handles1=strrep(str_handles1,'[]','@hessians');
    string_handles{5,1}=str_handles1;
    str_handles2=strrep(str_handles2,'[]','@hessiansp');
    string_handles{6,1}=str_handles2;
    str_init=strrep(str_init,strp_off,strp_on);string_init{2,1}=str_init;
    string_hess=system.struct.hess;string_hessp=system.struct.hessp;
end
if (exist('sym')==2&& system.struct.der(4,2)==1)
    string_hess  = cellstr(systems('symjac',handles,system.struct.equations,cor,pa,20));
    string_hessp = cellstr(systems('symjac',handles,system.struct.equations,cor,pa,21));
end    
if (system.struct.der(3,2)==1)
    string_hess  = cellstr(systems('replace_hess_input',system.struct.hess));
    string_hessp = cellstr(systems('replace_hessp_input',system.struct.hessp));
end
if (system.struct.der(4,3)==1), string_tensor3 = system.struct.tensor3;end
if (exist('sym')==2&& system.struct.der(4,3)==1)
    string_tensor3 = cellstr(systems('symjac',handles,system.struct.equations,cor,pa,3));
    str_handles2=string_handles{7};
    str_handles2=strrep(str_handles2,'[]','@der3');
    string_handles{7,1}=str_handles2;
end    
if (system.struct.der(4,4)==1), string_tensor4 = system.struct.tensor4;end
if (exist('sym')==2&& system.struct.der(4,4)==1)
    string_tensor4 = cellstr(systems('symjac',handles,system.struct.equations,cor,pa,4));
    str_handles2=string_handles{8};
    str_handles2=strrep(str_handles2,'[]','@der4');
    string_handles{8,1}=str_handles2;
end    
if (system.struct.der(4,5)==1), string_tensor5 = system.struct.tensor5;end
if (exist('sym')==2&& system.struct.der(4,5)==1)
    string_tensor5 = cellstr(systems('symjac',handles,system.struct.equations,cor,pa,5));
    str_handles2=string_handles{8};
    str_handles2=strrep(str_handles2,'[]','@der5');
    string_handles{8,1}=str_handles2;
end 
if ~isempty(system.struct.uf.UserfunctionsInfo)
    siz = size(system.struct.uf.UserfunctionsInfo,2);
    for i = 1:siz
        string_handles{9+i,1}= sprintf('out{%d}= @%s;',9+i,system.struct.uf.UserfunctionsInfo(i).name);
    end
else siz=0;end
h=0;
while feof(fid_read)==0
    tline   = fgetl(fid_read);
    h=h+1;
    if h==2
        for i=1:9+siz
            fprintf(fid_write,'%s\n',string_handles{i,1});
        end
    end        
    matches=strrep(tline,'time,',t);
    matches=strrep(matches,'odefile',system.struct.system);
    matches=strrep(matches,',parameters',par);
    fprintf(fid_write,'%s\n',matches);
    if isfield(system.struct,'userfunction')
        if ~isempty(findstr(matches,'varargout{1}=der5(coordinates,'))          
            for i = 1:size(system.struct.userfunction,2)
                hs1 = sprintf('case ''%s''\n\tvarargout{1}=%s(coordinates%s);',system.struct.uf.UserfunctionsInfo(i).name,system.struct.uf.UserfunctionsInfo(i).name,par);
                fprintf(fid_write,'%s\n',hs1);
            end
        end
    end        
    if ~isempty(findstr(matches,'function dydt'))
        dim = size(string_sys,1);         
        for i=1:dim
              string_sys{i};
              fprintf(fid_write,'%s\n',string_sys{i});
        end
    end
    if ~isempty(findstr(matches,'function [tspan,y0,options]'))
        dim = size(string_init,1);  
        for i=1:dim
              fprintf(fid_write,'%s\n',string_init{i});
        end
    end
    if (~isempty(findstr(matches,'function jac '))&& ~isempty(string_jac))
        dim = size(string_jac,1);         
        for i = 1:dim
              fprintf(fid_write,'%s\n',string_jac{i});
        end
    end   
    if (~isempty(findstr(matches,'function jacp'))&& ~isempty(string_jacp))
       dim = size(string_jacp,1);       
       for i = 1:dim
           fprintf(fid_write,'%s\n',string_jacp{i});
       end
    end    
    if (~isempty(findstr(matches,'function hess '))&& ~isempty(string_hess))
        dim = size(string_hess,1);        
        for i=1:dim
              fprintf(fid_write,'%s\n',string_hess{i});
        end
    end
    if (~isempty(findstr(matches,'function hessp'))&& ~isempty(string_hessp))
        dim = size(string_hessp,1);
        for i=1:dim
              fprintf(fid_write,'%s\n',string_hessp{i});
        end
    end
    if (~isempty(findstr(matches,'function tens3'))&& ~isempty(string_tensor3))
        dim = size(string_tensor3,1);
        for i = 1:dim
              fprintf(fid_write,'%s\n',string_tensor3{i});
        end
    end
    if (~isempty(findstr(matches,'function tens4'))&& ~isempty(string_tensor4))
        dim = size(string_tensor4,1);
        for i=1:dim
              fprintf(fid_write,'%s\n',string_tensor4{i});
        end
    end
    if (~isempty(findstr(matches,'function tens5'))&& ~isempty(string_tensor5))
        dim = size(string_tensor5,1);
        for i = 1:dim
              fprintf(fid_write,'%s\n',string_tensor5{i});
        end
    end
end
if ~isempty(system.struct.uf.UserfunctionsInfo)    
   for i=1:size(system.struct.uf.UserfunctionsInfo,2)
       res=0;
       if isfield(system.struct,'userfunction') && ~isempty(system.struct.userfunction{i})
           str_user = systems('replace_token',cellstr(system.struct.userfunction{i}));
       else 
           str_user=cellstr('res=');
       end
       hs1 = sprintf('function userfun%d=%s(t,kmrgd%s)',i,system.struct.uf.UserfunctionsInfo(i).name,par);
       fprintf(fid_write,'%s\n',hs1);
       hs1 = sprintf('userfun%d',i);
       dim = size(str_user,1);
       for j = 1:dim
           d = strmatch('res=',str_user{j},'exact');
           if findstr('res',str_user{j}),res=1;end
           str_user{j} = strrep(str_user{j},'res',hs1);
           if d==1
               fprintf(fid_write,'\t%s=0;\n',hs1);
           else 
               fprintf(fid_write,'\t%s;\n',str_user{j});
           end
       end
       if res==0,fprintf(fid_write,'\t%s=0;\n',hs1);end
   end
end        
fclose(fid_read);
fclose(fid_write);

delete(handles.userfunfig);


rehash;

