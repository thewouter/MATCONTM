
function varargout = systems(varargin)
% SYSTEM Application M-file for system.fig
%    FIG = SYSTEM launch system GUI.
%    SYSTEM('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 04-Dec-2001 09:15:45

if nargin == 0 ||((nargin ==1)&&(strcmp(varargin{1},'new'))) % LAUNCH GUI


	fig = openfig(mfilename,'reuse');
    
    % Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
   guidata(fig, handles);
   %checks if the symbolic toolbox is installed
   if (exist('sym')==2)
        set(handles.text14,'String','- symbolically');
        set(handles.f1,'Callback','systems(''symbolic_callback'',gcbo)');
        set(handles.f2,'Callback','systems(''symbolic_callback'',gcbo)');
        set(handles.f3,'Callback','systems(''symbolic_callback'',gcbo)');
        set(handles.f4,'Callback','systems(''symbolic_callback'',gcbo)');
        set(handles.f5,'Callback','systems(''symbolic_callback'',gcbo)');       
   end
    
    
    load_system(handles);
    if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

 %   try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
%	catch
	%	errordlg(lasterr,mfilename);
%         delete(driver_window);  
    %end

end

% --------------------------------------------------------------------
function ok_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.ok.
global system;
try 

    string_jac='';string_jacp='';string_hess='';string_hessp='';string_tensor3='';string_tensor4='';string_tensor5='';
    if isempty(system.struct.system)
        errordlg('You have to give the system a name','Name');
        return
    end
    par=get(handles.parameters,'String');
    if isempty(par)
        button = questdlg('The system has no parameters! Do you want to continue? ',...
        'Parameters','Yes','No','No');
        if strcmp(button,'No')
            return
        end
    end
    if (~isempty(par))
       par=strcat(',',par);
    end
    t=get(handles.time,'String');
    if (~isempty(t))
        t=strcat(t,',');
    end
    system.struct.equations=deblank(get(handles.sys,'String'));
    try
        string_sys=replace_sys_input(system.struct.equations);
    catch
        errordlg('Equations are in the wrong order, compared to the coordinates.','Error')
        return
    end
    if strcmp(string_sys,'error')
        errordlg('The left-hand sides do not match the coordinates.','Error');
        return
    end
    fwrite=strcat(system.struct.system,'.m');
    fwrite=fullfile(system.path_sys,fwrite);
    [fid_write,message]=fopen(fwrite,'w');
    if fid_write==-1
        errordlg(message,'Error');
        return
    end
    fread=fullfile(system.path_sys,'standard.m');
    [fid_read,message]=fopen(fread,'r');
    if fid_read==-1
        errordlg(message,'Error');
        return
    end


    set(handles.system , 'Visible', 'off');
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
    string_init=cellstr(make_init);
    cor=get(handles.coordinates,'String');
    pa=get(handles.parameters,'String');
    if (system.struct.der(3,1)==1||system.struct.der(4,1)==1)
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
        string_jac=cellstr(symjac(handles,system.struct.equations,cor,pa,10));
        string_jacp=cellstr(symjac(handles,system.struct.equations,cor,pa,11));
    end    
    if system.struct.der(3,1)==1
        string_jac=cellstr(replace_jac_input(system.struct.jac));
        string_jacp=cellstr(replace_jacp_input(system.struct.jacp));
    end
    if (system.struct.der(3,2)==1||system.struct.der(4,2)==1)
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
        string_hess=cellstr(symjac(handles,system.struct.equations,cor,pa,20));
        string_hessp=cellstr(symjac(handles,system.struct.equations,cor,pa,21));
    end    
    if (system.struct.der(3,2)==1)
        string_hess=cellstr(replace_hess_input(system.struct.hess));
        string_hessp=cellstr(replace_hessp_input(system.struct.hessp));
    end
    if (system.struct.der(4,3)==1), string_tensor3=system.struct.tensor3;end
    if (exist('sym')==2&& system.struct.der(4,3)==1)
        string_tensor3=cellstr(symjac(handles,system.struct.equations,cor,pa,3));
        str_handles2=string_handles{7};
        str_handles2=strrep(str_handles2,'[]','@der3');
        string_handles{7,1}=str_handles2;
    end    
    if (system.struct.der(4,4)==1), string_tensor4=system.struct.tensor4;end
    if (exist('sym')==2&& system.struct.der(4,4)==1)
        string_tensor4=cellstr(symjac(handles,system.struct.equations,cor,pa,4));
        str_handles2=string_handles{8};
        str_handles2=strrep(str_handles2,'[]','@der4');
        string_handles{8,1}=str_handles2;
    end    
    if (system.struct.der(4,5)==1), string_tensor5=system.struct.tensor5;end
    if (exist('sym')==2&& system.struct.der(4,5)==1)
        string_tensor5=cellstr(symjac(handles,system.struct.equations,cor,pa,5));
        str_handles2=string_handles{9};
        str_handles2=strrep(str_handles2,'[]','@der5');
        string_handles{9,1}=str_handles2;
    end 
    if   (isfield(system.struct , 'options') && isfield(system.struct.options , 'UserfunctionsInfo')  &&   ~isempty(system.struct.options.UserfunctionsInfo))
        siz = size(system.struct.options.UserfunctionsInfo,2);
        for i = 1:siz
            string_handles{9+i,1}= sprintf('out{%d}= @%s;',9+i,system.struct.options.UserfunctionsInfo(i).name);
        end
    else siz=0;end
    h=0;
    while feof(fid_read)==0
        tline=fgetl(fid_read);
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
                    hs1 = sprintf('case ''%s''\n\tvarargout{1}=%s(coordinates%s);',system.struct.options.UserfunctionsInfo(i).name,system.struct.options.UserfunctionsInfo(i).name,par);
                    fprintf(fid_write,'%s\n',hs1);
                end
            end
        end        
        if ~isempty(findstr(matches,'function dydt'))
            [dim,x]=size(string_sys);         
            for i=1:dim
                  fprintf(fid_write,'%s\n',string_sys{i});
            end
        end
        if ~isempty(findstr(matches,'handles'))
            [dim,x]=size(string_init);         
            for i=1:dim
                  fprintf(fid_write,'%s\n',string_init{i});
            end
        end
        if (~isempty(findstr(matches,'function jac '))&& ~isempty(string_jac))
            [dim,x]=size(string_jac);         
            for i=1:dim
                  fprintf(fid_write,'%s\n',string_jac{i});
            end
        end

        if (~isempty(findstr(matches,'function jacp'))&& ~isempty(string_jacp))
           [dim,x]=size(string_jacp);       
           for i=1:dim
               fprintf(fid_write,'%s\n',string_jacp{i});
           end
        end

        if (~isempty(findstr(matches,'function hess '))&& ~isempty(string_hess))
            [dim,x]=size(string_hess);        
            for i=1:dim
                  fprintf(fid_write,'%s\n',string_hess{i});
            end
        end
        if (~isempty(findstr(matches,'function hessp'))&& ~isempty(string_hessp))
            [dim,x]=size(string_hessp);
            for i=1:dim
                  fprintf(fid_write,'%s\n',string_hessp{i});
            end
        end
        if (~isempty(findstr(matches,'function tens3'))&& ~isempty(string_tensor3))
            [dim,x]=size(string_tensor3);
            for i=1:dim
                  fprintf(fid_write,'%s\n',string_tensor3{i});
            end
        end
        if (~isempty(findstr(matches,'function tens4'))&& ~isempty(string_tensor4))
            [dim,x]=size(string_tensor4);
            for i=1:dim
                  fprintf(fid_write,'%s\n',string_tensor4{i});
            end
        end
        if (~isempty(findstr(matches,'function tens5'))&& ~isempty(string_tensor5))
            [dim,x]=size(string_tensor5);
            for i=1:dim
                  fprintf(fid_write,'%s\n',string_tensor5{i});
            end
        end
    end
    if   (isfield(system.struct , 'options') && isfield(system.struct.options , 'UserfunctionsInfo')  &&   ~isempty(system.struct.options.UserfunctionsInfo))
       for i=1:size(system.struct.options.UserfunctionsInfo,2)
           str_user = []; res=0;
           if isfield(system.struct,'userfunction') && ~isempty(system.struct.userfunction{i})
               str_user = systems('replace_token',cellstr(system.struct.userfunction{i}));
           else 
               str_user=cellstr('res=');
           end
           hs1 = sprintf('function userfun%d=%s(t,kmrgd%s)',i,system.struct.options.UserfunctionsInfo(i).name,par);
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
                   fprintf(fid_write,'\t%s\n',str_user{j});
               end
           end
           if res==0,fprintf(fid_write,'\t%s=0;\n',hs1);end
       end
    end        

    fclose(fid_read);
    fclose(fid_write);
    file=fullfile(system.path_sys,system.struct.system);


    gds=system.struct; save(file,'gds'); clear gds;
    delete(handles.system);


    cd(system.path_sys);cd ..;  %GEVAARLIJK
    rehash;
catch err
    set(handles.system , 'Visible', 'on');
    warning on;
    warning(err.getReport());
    errordlg(['A fatal error occured during computation: ', err.message]);
    
end
% tempstr.label = 'Point';
% tempstr.Tag = 'P_O_DO';
% matcont('point_callback',tempstr)

% --------------------------------------------------------------------
function varargout = cancel_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.cancel.
global system ;
system.struct.system = ''; %delete system
load_system(handles);
delete(handles.system);

% --------------------------------------------------------------------
function varargout = coordinates_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.coordinates.
global system;
system.struct.coordinates=[];system.struct.plot2='';system.struct.plot3='';system.struct.PRC='';system.struct.dPRC='';
str=get(handles.coordinates,'String');
str=parse(str);
t=1;
for i=1:length(str)
    co{t,1}=str{i,1};
    string=str{i};
    str1=findstr(string,'[');
    str2=findstr(string,']');
    m=length(str1);
    if (m==length(str2)&&(m==1))
        num=str2double(string(str1+1:str2-1));
        var=string(1:str1-1);
        co{t,1}=strcat(var,'(1)');
        if num>1
            for j=2:num
                t=t+1;
                co{t,1}=strcat(var,'(',num2str(j),')');
            end
        end
    end
    t=t+1;
end
system.struct.coordinates=co;
system.struct.dim=size(system.struct.coordinates,1);
if ((system.struct.dim==1)&&(strcmp(system.struct.coordinates{1},'')))
    system.struct.coordinates=[];
    system.struct.dim=0;
else
    for i=1:(system.struct.dim)
    system.struct.coordinates{i,2}=0;
    end
end
for i=1:system.struct.dim
    if strcmp(upper(system.struct.coordinates{i}),'C')
        erdlg=sprintf('%s can not be used as a coordinate!',system.struct.coordinates{i});
        errordlg(erdlg,'wrong coordinate');
        set(handles.coordinates,'String','');system.struct.coordinates=[];system.struct.dim=0;
        return
    end
end


% --------------------------------------------------------------------
function varargout = parameters_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.parameters.
global system;
system.struct.parameters=[];
system.struct.T=[];system.struct.eps0=[];system.struct.eps1=[];system.struct.extravec=[1 0 0]; system.struct.t=[]; system.struct.epsilon=[];
system.struct.plot2='';system.struct.plot3='';system.struct.PRC='';system.struct.dPRC='';
str=get(handles.parameters,'String');
system.struct.parameters=parse(str);
[ndim,x]=size(system.struct.parameters);
for i=1:ndim
    if strcmp(system.struct.parameters{i},'kmrgd')||strcmp(upper(system.struct.parameters{i}),'C')
        erdlg=sprintf('%s can not be used as a parameter!',system.struct.parameters{i});
        errordlg(erdlg,'wrong parameter');
        set(handles.parameters,'String','');system.struct.parameters=[];
        return
    end
end
if (~isempty(system.struct.jacp))||(~isempty(system.struct.hessp))
    str=sprintf('Don''t forget to change jacobianp/hessianp \n you also have to change ''df..d..='' etc.');
    warndlg(str,'warning!!');
end
if ((ndim==1)&&(strcmp(system.struct.parameters{1},'')))
    system.struct.parameters=[];
else
    for i=1:ndim
    system.struct.parameters{i,2}=0;
    end
end
  
% --------------------------------------------------------------------
function varargout = time_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.time.
global system
system.struct.time=[];
str=get(handles.time,'String');
system.struct.time=str;

% --------------------------------------------------------------------
function varargout = name_system_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.name_system.
global system 
str1=get(handles.name_system,'String');
str1=strrep(str1,'.m','');
str=strcat(str1,'.m');
file=fullfile(system.path_sys,str);
if (exist(file)==2)
    warning_box(str1,file,handles);
else 
    w=which(str);
    if ~isempty(w)
        errordlg('This name is already in use for another function (Possibly in Matlab itself).','wrong name');
        set(handles.name_system,'String','');system.struct.system='';
        return
    end
    system.struct.system=str1;
end

% --------------------------------------------------------------------
function varargout = edit8_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.edit8
global system
system.struct.equations=[];

% --------------------------------------------------------------------
function varargout = numerically_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.n1.
global system
t=get(h,'Tag');
num=str2double(strtok(t,'n'));
set(h,'Value',1);
system.struct.der(1,num)=1;system.struct.der(2,num)=0;
system.struct.der(3,num)=0;system.struct.der(4,num)=0;
set(0,'ShowHiddenHandles','on');
hf=findobj('Tag',strcat('f',num2str(num)));
hr=findobj('Tag',strcat('r',num2str(num)));
val=get(hr,'Value');
if (val==1)
  edit=findobj('Tag','edit');  stat=findobj('Tag','stat');
  editp=findobj('Tag','editp');  statp=findobj('Tag','statp');
  delete(edit);  delete(stat);
  delete(editp);  delete(statp);
end
set(0,'ShowHiddenHandles','off');
pos=[0.0335 0.09 0.925 0.47];
set(handles.sys,'Position',pos);
set(hf,'Value',0);set(hr,'Value',0);
% --------------------------------------------------------------------
function varargout = routine_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.r1.
global system
p=0;jac='';jacp='';hess='';hessp='';
for j=1:system.struct.dim
    for i=1:system.struct.dim
        p=p+1;
        jac{p,1}=strcat('df',system.struct.coordinates{j,1},'d',system.struct.coordinates{i,1},'=');
    end
end
p=0;
for j=1:system.struct.dim
    for i=1:system.struct.dim
        for m=1:system.struct.dim
            p=p+1;
            hess{p,1}=strcat('df',system.struct.coordinates{j,1},'d',system.struct.coordinates{i,1},'d',system.struct.coordinates{m,1},'=');
        end
    end     
end
dimp=size(system.struct.parameters,1);
if (dimp==0)
    jacp='';hessp='';
else
    p=0;
    for j=1:system.struct.dim
        for i=1:dimp
            p=p+1;
            jacp{p,1}=strcat('df',system.struct.coordinates{j,1},'d',system.struct.parameters{i,1},'=');
        end
    end
    p=0;
    for j=1:system.struct.dim
        for i=1:system.struct.dim
            for m=1:dimp
                p=p+1;
                hessp{p,1}=strcat('df',system.struct.coordinates{j,1},'d',system.struct.coordinates{i,1},'d',system.struct.parameters{m,1},'=');
            end
        end     
    end
end
set(h,'Value',1);
t=get(h,'Tag');
num=str2double(strtok(t,'r'));
set(0,'ShowHiddenHandles','on');
hf=findobj('Tag',strcat('f',num2str(num)));
hn=findobj('Tag',strcat('n',num2str(num)));
hn=findobj('Tag',strcat('n',num2str(num)));
edit=findobj('Tag','edit');stat=findobj('Tag','stat');
editp=findobj('Tag','editp');statp=findobj('Tag','statp');
delete(edit);delete(stat);
delete(editp);delete(statp);
set(0,'ShowHiddenHandles','off');
system.struct.der(3,num)=1;system.struct.der(1,num)=0;
system.struct.der(2,num)=0;system.struct.der(4,num)=0;
set(hf,'Value',0);set(hn,'Value',0);
pos=[0.0335 0.34 0.925 0.23];
set(handles.sys,'Position',pos);
color=get(0,'defaultUicontrolBackgroundColor');
switch num
        case 1, 
            string='1st order derivatives'; stringp='Enter the jacobianp';
        case 2,
             string='2nd order derivatives';stringp='Enter the hessianp';
        case 3,
             string='3thd order derivatives';
        otherwise, 
             string='4th order derivatives';    
end
poss=  [0.0335 0.31 0.925 0.029];pose=  [0.0335 0.09 0.925 0.22];
posje1=[0.0335 0.21 0.925 0.10];posjs= [0.0335 0.18 0.925 0.03];
posje2=[0.0335 0.09 0.925 0.09];
stat=uicontrol(handles.system,'Style','text','HorizontalAlignment','left','String',string,'Tag','stat','BackGroundColor',color,'Units','normalized','Position',poss,'fontname','FixedWidth','fontsize',12);
%if ((num==1)&&~isempty(system.struct.jac))
 %       str=system.struct.jac; strp=system.struct.jacp;
 %els
 if (num==1)
    system.struct.jac='';system.struct.jacp='';
    str=jac; strp=jacp;
        %elseif ((num==2)&& ~isempty(system.struct.hess))
       % str=system.struct.hess; strp=system.struct.hessp;
elseif (num==2)
   system.struct.hess='';system.struct.hessp='';
   str=hess; strp=hessp;
else
   str=''; strp='';
end
edit=uicontrol(handles.system,'Style','edit','String',str,'HorizontalAlignment','left','Tag','edit','BackGroundColor',[1 1 1],'Max',40,'Callback','der_callback','Userdata',num,'Units','normalized','Position',pose,'fontname','FixedWidth','fontsize',12);
if ((num==1)&&(dimp~=0))||((num==2)&&(dimp~=0))
  edit=uicontrol(handles.system,'Style','edit','String',str,'HorizontalAlignment','left','Tag','edit','BackGroundColor',[1 1 1],'Max',40,'Callback','der_callback','Userdata',num,'Units','normalized','Position',posje1,'fontname','FixedWidth','fontsize',12); 
  stat_p=uicontrol(handles.system,'Style','text','HorizontalAlignment','left','String',stringp,'Tag','statp','BackGroundColor',color,'Units','normalized','Position',posjs);  
  edit_p=uicontrol(handles.system,'Style','edit','String',strp,'HorizontalAlignment','left','Tag','editp','BackGroundColor',[1 1 1],'Max',40,'Callback','der_callback','Userdata',num,'Units','normalized','Position',posje2,'fontname','FixedWidth','fontsize',12);
end

%-------------------------------------------------------------------
function varargout = file_callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.r1.
global system
p=0;
t=get(h,'Tag');
num=str2double(strtok(t,'f'));
switch num
case 1
    prompt  = {'Enter the file name of the jacobian:','Enter the file name of the jacobianp:'};
    title   = 'Input name of derivative-file';
    lines= 1;
    def     = {'',''};
    answer  = inputdlg(prompt,title,lines,def);
    if isempty(answer)||isempty(answer{1})||isempty(answer{2})
       set(h,'Value',0);
       return;
    end
    jacobian=answer{1};jacobianp=answer{2};
    system.struct.jac=parsefile(jacobian);
    system.struct.jacp=parsefile(jacobianp);
    system.struct.jac=strcat('jac=',replace_token(system.struct.jac),';');system.struct.jacp=strcat('jacp=',replace_token(system.struct.jacp),';');
case 2
    prompt  = {'Enter the file name of the hessian:','Enter the file name of the hessianp:'};
    title   = 'Input name of derivative-file';
    lines= 1;
    def     = {'',''};
    answer  = inputdlg(prompt,title,lines,def);
    if isempty(answer)|| isempty(answer{1})||isempty(answer{2})
       set(h,'Value',0);
       return;
    end
    hessian=answer{1};hessianp=answer{2};
    system.struct.hess=[];system.struct.hessp=[];
    hess=parsefile(hessian);hess=replace_token(hess);
    hessp=parsefile(hessianp);hessp=replace_token(hessp);
    for i=1:system.struct.dim
        system.struct.hess{i,1}=strcat('hess',num2str(i),'=',hess{i,1},';');
        system.struct.hess{system.struct.dim+i,1}=strcat('hess','(:,:,',num2str(i),') =','hess',num2str(i),';');
    end
    dimp=size(system.struct.parameters,1);
    for  i=1:dimp
        system.struct.hessp{i,1}=strcat('hessp',num2str(i),'=',hessp{i,1},';');
        system.struct.hessp{dimp+i,1}=strcat('hessp','(:,:,',num2str(i),') =','hessp',num2str(i),';');
    end
case {3,4,5}
    prompt  = {'Enter the file name of the tensor:'};
    title   = 'Input name of derivative-file';
    lines= 1;
    def     = {''};
    answer  = inputdlg(prompt,title,lines,def);
    if isempty(answer)||isempty(answer{1})
       set(h,'Value',0);
       return;
    end
    tensor=answer{1};
    tens=parsefile(tensor);tens=replace_token(tens);
    switch num
    case 3
        dim=system.struct.dim*system.struct.dim;
        system.struct.tensor3=[];j=0;
        for i=1:dim
            if (mod(i,system.struct.dim)==1),j=j+1;end
            k=mod(i,system.struct.dim);if (k==0),k=system.struct.dim;end
            system.struct.tensor3{i,1}=strcat('tens3',num2str(i),'=',tens{i},';');
            system.struct.tensor3{dim+i,1}=strcat('tens3','(:,:,',num2str(j),',',num2str(k),') =','tens3',num2str(i),';');
        end
    case 4
        dim=(system.struct.dim)^3;
        system.struct.tensor4=[];j=0;d=0;
        for  i=1:dim
            k=mod(i,system.struct.dim);if (k==0),k=system.struct.dim;end
            if (mod(i,system.struct.dim)==1),j=j+1;end
            j=mod(j,system.struct.dim);if j==0,j=system.struct.dim;end
            if (mod(i,system.struct.dim*system.struct.dim)==1),d=d+1;end
            system.struct.tensor4{i,1}=strcat('tens4',num2str(i),'=',tens{i},';');
            system.struct.tensor4{dim+i,1}=strcat('tens4','(:,:,',num2str(d),',',num2str(j),',',num2str(k),') =','tens4',num2str(i),';');
        end
    case 5
        dim=(system.struct.dim)^4;
        system.struct.tensor4=[];j=0;d=0;p=0;
        for i=1:dim
            k=mod(i,system.struct.dim);if (k==0),k=system.struct.dim;end
            if (mod(i,system.struct.dim)==1),j=j+1;end
            j=mod(j,system.struct.dim);if j==0,j=system.struct.dim;end
            if (mod(i,system.struct.dim*system.struct.dim)==1),d=d+1;end
            d=mod(d,system.struct.dim);if d==0,d=system.struct.dim;end
            if (mod(i,(system.struct.dim)^3)==1),p=p+1;end
            system.struct.tensor5{i,1}=strcat('tens5',num2str(i),'=',tens{i},';');
            system.struct.tensor4{dim+i,1}=strcat('tens5','(:,:,',num2str(p),',',num2str(d),',',num2str(j),',',num2str(k),') =','tens5',num2str(i),';');
        end
    end
end
jac='';jacp='';hess='';hessp='';tens='';
set(h,'Value',1);t=get(h,'Tag');
set(0,'ShowHiddenHandles','on');
hr=findobj('Tag',strcat('r',num2str(num)));
hn=findobj('Tag',strcat('n',num2str(num)));
val=get(hr,'Value');
if (val==1)   
    edit=findobj('Tag','edit');stat=findobj('Tag','stat');
    editp=findobj('Tag','editp');statp=findobj('Tag','statp');
    delete(edit);delete(stat);delete(editp);delete(statp);
end
set(0,'ShowHiddenHandles','off');
pos=[0.0335 0.09 0.925 0.47];
set(handles.sys,'Position',pos);
system.struct.der(4,num)=1;system.struct.der(1,num)=0;
system.struct.der(2,num)=0;system.struct.der(3,num)=0;
set(hr,'Value',0);set(hn,'Value',0);  
    
%-------------------------------------------------------------------
function varargout = symbolic_callback(h)
% Stub for Callback of the uicontrol handles.r1.
global system
p=0;jac='';jacp='';hess='';hessp='';tens='';
set(h,'Value',1);t=get(h,'Tag');
num=str2double(strtok(t,'f'));
set(0,'ShowHiddenHandles','on');
hr=findobj('Tag',strcat('r',num2str(num)));
hn=findobj('Tag',strcat('n',num2str(num)));
hsys=findobj('Tag','sys');
val=get(hr,'Value');
if (~isempty(val) && (val==1))   
    edit=findobj('Tag','edit');stat=findobj('Tag','stat');
    editp=findobj('Tag','editp');statp=findobj('Tag','statp');
    delete(edit);delete(stat);delete(editp);delete(statp);
end
set(0,'ShowHiddenHandles','off');
pos=[0.0335 0.09 0.925 0.47];
set(hsys,'Position',pos);
system.struct.der(4,num)=1;system.struct.der(1,num)=0;
system.struct.der(2,num)=0;system.struct.der(3,num)=0;
set(hr,'Value',0);set(hn,'Value',0);

%-------------------------------------------------------------------
function sym_jac = symjac(handles,string,cor,p1e,number)
% Stub for Callback of the uicontrol handles.r1.
global system;
%string=get(handles.sys,'String');
dimp=size(system.struct.parameters,1);
if isempty(string)
    string = '';
    return
end
string_sys = cellstr(string);
string=''; tempory = '';equation = '';
for j1e = 1:(system.struct.dim)
    syss{j1e} = strcat(system.struct.coordinates{j1e,1},char(39));
end
[tempory,equation] = parse_input(string_sys,syss);
num_temp = size(tempory,1);
for i1e = 1:num_temp
    string{i1e,1} = strcat(tempory{i1e,1},';');
end
num_eq = size(equation,1);
for i1e=1:num_eq
    string{num_temp+i1e,1} = '';
end
for j1e = 1:num_eq
      [null,string{num_temp+j1e,1}] = strtok(equation{j1e,1},'=');
      string{num_temp+j1e,1} = strtok(string{num_temp+j1e,1},'=');
      string{num_temp+j1e,1} = strcat(string{num_temp+j1e,1},';');
end
string{num_temp+1,1} = strcat('dydt=[',string{num_temp+1,1});
string{num_temp+num_eq,1} = strcat(string{num_temp+num_eq,1},'];');
if (num_eq~=system.struct.dim)
  string='error';
  return;
end
strings=char(string);
cor=strrep(cor,',',' ');
cors=sprintf('syms %s',cor);eval(cors);
p1a=strrep(p1e,',',' ');
p1e=sprintf('syms %s',p1a);eval(p1e);
stri='';
for i1ee=1:size(strings,1)
    stri=strcat(stri,strings(i1ee,:));
end
eval(stri);
cors=strcat('[',cor,']');
jac=jacobian(dydt,eval(cors));
if number==10% case jacobian
    j1c = symmat2line(jac);
    sym_jac=replace_token(cellstr(strcat('jac=',j1c,';')));
    
elseif number==11 %case jacobianp
    p1a=strcat('[',p1a,']');
    j1p= symmat2line( jacobian(dydt,eval(p1a)) );
    sym_jac=replace_token(cellstr(strcat('jacp=',j1p,';')));
   
elseif number==20 %case hessians
    system.struct.hess=[];
    for i1e=1:system.struct.dim
        h1s=symmat2line( diff(jac,eval(system.struct.coordinates{i1e,1})) );
        system.struct.hess{i1e,1}=strcat('hess',num2str(i1e),'=',h1s,';');
        system.struct.hess{system.struct.dim+i1e,1}=strcat('hess','(:,:,',num2str(i1e),') =','hess',num2str(i1e),';');
    end
    sym_jac=replace_token(cellstr(system.struct.hess));
elseif number==21 % case hessianp
    system.struct.hessp=[];
    for  i1e=1:dimp
        h1sp = symmat2line(   diff(jac,eval(system.struct.parameters{i1e,1}))    );
        system.struct.hessp{i1e,1}=strcat('hessp',num2str(i1e),'=',h1sp,';');
        system.struct.hessp{dimp+i1e,1}=strcat('hessp','(:,:,',num2str(i1e),') =','hessp',num2str(i1e),';');
    end
    sym_jac=replace_token(cellstr(system.struct.hessp));

elseif number==3
    dim=system.struct.dim*system.struct.dim;
    system.struct.tensor3=[];je1=0;if(dim==1),je1=1;end
    for  i1e=1:dim
        if (mod(i1e,system.struct.dim)==1),je1=je1+1;end
        ke1=mod(i1e,system.struct.dim);
        if (ke1==0),ke1=system.struct.dim;end
        he1=diff(jac,eval(system.struct.coordinates{je1,1}));
        h2s=diff(he1,eval(system.struct.coordinates{ke1,1}));
        
        h2s = symmat2line( h2s );
        system.struct.tensor3{i1e,1}=strcat('tens3',num2str(i1e),'=',h2s,';');
        system.struct.tensor3{dim+i1e,1}=strcat('tens3','(:,:,',num2str(je1),',',num2str(ke1),') =','tens3',num2str(i1e),';');
    end 
    sym_jac=replace_token(cellstr(system.struct.tensor3));
elseif number==4
    dim=(system.struct.dim)^3;
    system.struct.tensor4=[];je1=0;de1=0;if(dim==1),je1=1;de1=1;end
    for  i1e=1:dim
        ke1=mod(i1e,system.struct.dim);if (ke1==0),ke1=system.struct.dim;end
        if (mod(i1e,system.struct.dim)==1),je1=je1+1;end
        je1=mod(je1,system.struct.dim);if je1==0,je1=system.struct.dim;end
        if (mod(i1e,system.struct.dim*system.struct.dim)==1),de1=de1+1;end
        he1=diff(jac,eval(system.struct.coordinates{de1,1}));
        h2s=diff(he1,eval(system.struct.coordinates{je1,1}));
        h3s=diff(h2s,eval(system.struct.coordinates{ke1,1}));
        
        h3s = symmat2line( h3s );
        system.struct.tensor4{i1e,1}=strcat('tens4',num2str(i1e),'=',h3s,';');
        system.struct.tensor4{dim+i1e,1}=strcat('tens4','(:,:,',num2str(de1),',',num2str(je1),',',num2str(ke1),') =','tens4',num2str(i1e),';');
    end 
    sym_jac=replace_token(cellstr(system.struct.tensor4));
elseif number==5
    dim=(system.struct.dim)^4;
    system.struct.tensor5=[];je1=0;de1=0;pe1=0;if(dim==1),je1=1;de1=1;pe1=1;end
    for  i1e=1:dim
        ke1=mod(i1e,system.struct.dim);if (ke1==0),ke1=system.struct.dim;end
        if (mod(i1e,system.struct.dim)==1),je1=je1+1;end
        je1=mod(je1,system.struct.dim);if je1==0,je1=system.struct.dim;end
        if (mod(i1e,system.struct.dim*system.struct.dim)==1),de1=de1+1;end
        de1=mod(de1,system.struct.dim);if de1==0,de1=system.struct.dim;end
        if (mod(i1e,system.struct.dim*system.struct.dim*system.struct.dim)==1),pe1=pe1+1;end
        he1=diff(jac,eval(system.struct.coordinates{pe1,1}));
        h2s=diff(he1,eval(system.struct.coordinates{de1,1}));
        h3s=diff(h2s,eval(system.struct.coordinates{je1,1}));
        h4s=diff(h3s,eval(system.struct.coordinates{ke1,1}));
        
        h4s = symmat2line( h4s );
        system.struct.tensor5{i1e,1}=strcat('tens5',num2str(i1e),'=',h4s,';');
        system.struct.tensor5{dim+i1e,1}=strcat('tens5','(:,:,',num2str(pe1),',',num2str(de1),',',num2str(je1),',',num2str(ke1),') =','tens5',num2str(i1e),';');
    end 
    sym_jac=replace_token(cellstr(system.struct.tensor5));
end
    

%--------------------------------------------------------------------
function varargout=load_system(handles)
global system
co='';par='';
if ((system.struct.dim)~=0)
    co=system.struct.coordinates{1,1};
end
if ((system.struct.dim)>=2)
  for i=2:system.struct.dim
       co=horzcat(co,',',system.struct.coordinates{i,1});
  end
end
dim=size(system.struct.parameters,1);
if (dim~=0)
    par=system.struct.parameters{1,1};
end
if (dim>=2)
   for i=2:dim
        par=horzcat(par,',',system.struct.parameters{i,1});
   end
end  
set(handles.name_system,'String',system.struct.system);
set(handles.coordinates,'String',co);
set(handles.parameters,'String',par);
set(handles.time,'String',system.struct.time{1,1});
set(handles.sys,'String',system.struct.equations);
set(handles.n1,'Value',system.struct.der(1,1));
set(handles.n2,'Value',system.struct.der(1,2));
set(handles.n3,'Value',system.struct.der(1,3));
set(handles.n4,'Value',system.struct.der(1,4));
set(handles.n5,'Value',system.struct.der(1,5));
set(handles.f1,'Value',system.struct.der(4,1));
set(handles.f2,'Value',system.struct.der(4,2));
set(handles.f3,'Value',system.struct.der(4,3));
set(handles.f4,'Value',system.struct.der(4,4));
set(handles.f5,'Value',system.struct.der(4,5));
set(handles.r1,'Value',system.struct.der(3,1));
if (system.struct.der(3,1)==1)
    routine_Callback(handles.r1,[],guidata(handles.r1));
end
set(handles.r2,'Value',system.struct.der(3,2));
if (system.struct.der(3,2)==1)
    routine_Callback(handles.r2,[],guidata(handles.r2));
end
guidata(handles.system,handles);

%---------------------------------------------------------------------
function all=parse(input_string)
global system;
remainder=input_string;
all='';
while (any(remainder))
[chopped,remainder]=strtok(remainder,',');
all=strvcat(all,chopped);
end
all=cellstr(all);

%--------------------------------------------------------------------
function string=replace_sys_input(string)
global system;
if isempty(string)
    string = '';
    return
end
string_sys = cellstr(string);
string=''; temp = '';eq = '';
for j = 1:(system.struct.dim)
    sys{j} = strcat(system.struct.coordinates{j,1},char(39));
end
[temp,eq] = parse_input(string_sys,sys);
num_temp = size(temp,1);
for i = 1:num_temp
    string{i,1} = strcat(temp{i,1},';');
end
num_eq = size(eq,1);
for i=1:num_eq
    string{num_temp+i,1} = '';
end
for j = 1:num_eq
      [null,string{num_temp+j,1}] = strtok(eq{j,1},'=');
      string{num_temp+j,1} = strtok(string{num_temp+j,1},'=');
      string{num_temp+j,1} = strcat(string{num_temp+j,1},';');
end
string{num_temp+1,1} = strcat('dydt=[',string{num_temp+1,1});
string{num_temp+num_eq,1} = strcat(string{num_temp+num_eq,1},'];');
if (num_eq~=system.struct.dim)
  string='error';
  return;
end
string = replace_token(string);

%--------------------------------------------------------------------
function string = replace_jac_input(string)
global system;
if isempty(string)
    string = '';
    return
end
string_jac = cellstr(string);
string=''; temp = ''; eq = '';
p = 0;
for j = 1:system.struct.dim
    for i = 1:system.struct.dim
        p = p+1;
        jac{p,1} = strcat('df',system.struct.coordinates{j,1},'d',system.struct.coordinates{i,1});
    end
end
[temp,eq] = parse_input(string_jac,jac);
string = make_mat(temp,eq,jac,system.struct.dim,'jac');
string = replace_token(string);

%--------------------------------------------------------------------
function string = replace_jacp_input(string)
global system;
if isempty(string)
    string = '';
    return
end
string_jacp = cellstr(string);
string=''; temp = ''; eq ='';
p = 0;
dimp = size(system.struct.parameters,1);
for j = 1:system.struct.dim
    for i = 1:dimp
        p = p+1;
        jacp{p,1} = strcat('df',system.struct.coordinates{j,1},'d',system.struct.parameters{i,1});
    end
end
[temp,eq] = parse_input(string_jacp,jacp);
string = make_mat(temp,eq,jacp,dimp,'jacp');
string = replace_token(string);

%-----------------------------------------------------------------------------
function string = replace_hess_input(string)
global system;
if isempty(string)
    string = '';
    return
end
string_hess = cellstr(string);
string ='';temp =''; eq ='';
p = 0;
for j = 1:system.struct.dim
    for i = 1:system.struct.dim
        for m = 1:system.struct.dim
            p = p+1;
            hess{p,1} = strcat('df',system.struct.coordinates{j,1},'d',system.struct.coordinates{i,1},'d',system.struct.coordinates{m,1});
        end
    end     
end
[temp,eq] = parse_input(string_hess,hess);
string = make_mathess(temp,eq,hess,system.struct.dim,'hess');
string = replace_token(string);

%-----------------------------------------------------------------------
function string=replace_hessp_input(string)
global system;
if isempty(string)
    string = '';
    return
end
string_hessp = cellstr(string);
string=''; temp =''; eq ='';
dimp = size(system.struct.parameters,1);
p = 0;
for j = 1:system.struct.dim
    for i = 1:system.struct.dim
        for m = 1:dimp
            p = p+1;
            hessp{p,1} = strcat('df',system.struct.coordinates{j,1},'d',system.struct.coordinates{i,1},'d',system.struct.parameters{m,1});
        end
    end     
end
[temp,eq] = parse_input(string_hessp,hessp);
string = make_mathess(temp,eq,hessp,dimp,'hessp');
string = replace_token(string);

%--------------------------------------------------------------------
function string = replace_token(string)
global system
token = strcat('[],;=/*-+ ^()!"',char(39));
dim = size(string,1);
for t=1:dim
    for i=1:(system.struct.dim)
        repl = string{t,1};
        m = findstr(repl,system.struct.coordinates{i,1});
        p = length(m);
        h = length(system.struct.coordinates{i,1});
        j = num2str(i);
        x = strcat('kmrgd(',j,')');
        len = length(x);
        w = 0;
        if p>0
            for g = 1:p
                if (m(g) > 1)  
                    k = findstr(repl(m(g)-1+w*(len-h)),token);
                else
                    k = 1;
                end
                if ((m(g)+h+w*(len-h)) < length(repl))                 
                    s = findstr(repl(m(g)+h+w*(len-h)),token);
                else
                    s = 1;
                end
                if (~isempty(s) && ~isempty(k))
                    repl((m(g)+w*(len-h)):(m(g)+h-1+w*(len-h))) = '';
                    if(m(g)>1)
                        y = m(g)-1+w*(len-h);
                        repl = sprintf('%s%s%s',repl(1:(m(g)-1+w*(len-h))),x,repl(m(g)+w*(len-h):end));
                    else 
                        repl = sprintf('%s%s',x,repl(m(g)+w*(len-h):end));
                    end
                    string{t,1} = repl;
                    w = w+1;
                end
            end
        end
    end
end
%---------------------------------------------------------------------------
function [temp,eq] = parse_input(string,type)
dim = size(string,1);
vars = size(type,2);
temp='';eq='';
p=1;s=1;
for j=1:dim
    k=[];  
    for i=1:length(type)
        teststring = string{j};
        if exist('strtrim','builtin')
            x = findstr(teststring(1:length(strtrim(type{i}))),strtrim(type{i}));
        else
            x = findstr(teststring(1:length(strtrim(type{i}))),deblank(type{i}));
        end
        if ~isempty(x)
           k = 1;
           tmpv = type{1};
           if (vars-i ~= dim-j) && (tmpv(end) == '''')
               error('Equations are in the wrong order, compared to the coordinates.');
           end
        end
    end
    if (findstr(string{j},'=')&(isempty(k)))
        temp{p,1} = string{j};
        h = 1; c = 0; p = p+1;
     elseif (findstr(string{j},'=')&~(isempty(k)))
             eq{s,1} = string{j};
             h = 0; c = 1; s = s+1;
     elseif (~findstr(string{j},'='))
          if (h==1)
             temp{p,1} = strcat(temp{p,1},string{j});
             p = p+1;
          elseif (c==1)
                  eq{s,1} = strcat(eq{s,1},string{j});
                  s = s+1;
          end
    end
end

%-------------------------------------------------------------------------
function string=make_mat(temp,eq,type,dim,str)
global system;
num_temp=size(temp,1);
for i=1:num_temp
    string{i,1} = strcat(temp{i,1},';');
end
for i=1:(system.struct.dim)
    string{num_temp+i,1} = '';
end
num_eq = size(eq,1);
t = 0 ; p = 1;
for j=1:length(type)
    for i=1:num_eq        
         x = findstr(eq{i,1},type{j,1});
         if ~isempty(x)
            [null,eq{i,1}] = strtok(eq{i,1},'=');
            eq{i,1} = strtok(eq{i,1},'=');
            if isempty(eq{i,1})
               eq{i,1} = 0;
            end
            t = t+1;
            if (t==(dim+1))
                p = p+1;
                t = 1;
            end
            string{num_temp+p,1} = sprintf('%s%c%c%c%s',string{num_temp+p,1},char(32),char(32),char(32),eq{i,1});
            eq{i,1} = '';    
        end 
    end
end        
for i=1:system.struct.dim
    string{num_temp+i,1} = strcat(string{num_temp+i},';');
end
string{num_temp+1,1} = strcat(str,'=[',string{num_temp+1,1});
string{num_temp+(system.struct.dim),1} = strcat(string{num_temp+(system.struct.dim),1},'];');

%-----------------------------------------------------------------------
function string=make_mathess(temp,eq,type,dim,str)
global system
num_temp = size(temp,1);
if num_temp>0
   for i=1:num_temp
       string{i} = strcat(temp{i,1},';');
   end
end
for i=1:(dim*system.struct.dim+dim)
    string{num_temp+i,1} ='';
end
num_eq = size(eq,1);
eq = sort(eq);
p = 1; r = 0; t = 0;
for m=1:dim
    for j=m:dim:length(type)
        for i=1:num_eq
            x = findstr(eq{i,1},type{j,1});
            if ~isempty(x)
               [null,eq{i,1}] = strtok(eq{i,1},'=');    
               eq{i,1} = strtok(eq{i,1},'=');
               if isempty(eq{i,1})
                  eq{i,1} = 0;
               end
               t = t+1;
               if (t==(system.struct.dim+1))
                  p = p+1;
                  t = 1;
               end
               string{num_temp+p,1} = sprintf('%s%c%c%s',string{num_temp+p,1},char(32),char(32),eq{i,1});
               eq{i,1} = '';
           end 
        end
    end        
    for i=1:system.struct.dim
        r=r+1;  
        string{num_temp+r,1} = strcat(string{num_temp+r},';');
    end
    string{num_temp+r-(system.struct.dim)+1,1} = strcat(str,num2str(m),'=[',string{num_temp+r-(system.struct.dim)+1,1});
    string{num_temp+r,1} = strcat(string{num_temp+r,1},'];');
end
for i=1:dim
string{num_temp+r+i,1} = strcat(str,'(:,:,',num2str(i),') =',str,num2str(i),';');
end

%------------------------------------------------------------------------
function init
global system;
    system.struct = []; system.struct.coordinates = []; system.struct.parameters = [];
    system.struct.time{1,1} = 't';system.struct.time{1,2} = 0; 
    system.struct.system = '';
    system.struct.curve.new = '';system.struct.curve.old = '';
    system.struct.equations = [];
    system.struct.dim = 0;
    system.struct.der = [[1 1 1 1 1];zeros(3,5)]; 
    system.struct.jac = '';%string that contains the jacobian
    system.struct.jacp = '';%string that contains the jacobianp
    system.struct.hess = '';%string that contains the hessian
    system.struct.hessp = '';%string that contains the hessianp
    system.struct.tensor3 = ''; system.struct.tensor4 = ''; system.struct.tensor5 = '';
    system.struct.point = ''; system.struct.type = '';
    system.struct.discretization.ntst = 20; system.struct.discretization.ncol = 4;
    system.struct.period = 1;
    system.struct.plot2 = '';system.struct.plot3 = '';system.struct.PRC='';system.struct.dPRC='';
    system.struct.open.figuur = 0; system.struct.open.continuer = 0; system.struct.open.numeric_fig = 0;
    system.struct.open.D2 = 0;system.struct.open.D3 = 0;system.struct.open.PRC = 0; system.struct.open.dPRC = 0; system.struct.open.integrator = 0;
    system.struct.integrator = []; system.struct.integrator.method = 'ode45'; system.struct.integrator.options = [];
    system.struct.integrator.tspan = [0 1]; system.struct.numeric = [];
    system.struct.numeric.O = {'time' 1;'coordinates' 1;'parameters' 0'};
    %system.struct.numeric.EP = {'coordinates' 1;'parameters' 1;'testfunctions' 0;'eigenvalues' 0;'current stepsize' 0};
    system.struct.numeric.FP = {'coordinates' 1;'parameters' 1;'testfunctions' 0;'multipliers' 0;'current stepsize' 0};
    % XXXX
    %system.struct.numeric.LC = {'parameters' 1;'period' 1;'testfunctions' 0;'multipliers' 0;'current stepsize' 0};
    system.struct.numeric.LC = {'parameters' 1;'period' 1;'testfunctions' 0;'multipliers' 0;'current stepsize' 0;'PRC' 0;'dPRC' 0;'Input' 0};
    % XXXX
    system.struct.numeric.PD = {'parameters' 1;'period' 1;'testfunctions' 0;'multipliers' 0;'current stepsize' 0};
    % XXX
    system.struct.numeric.Hom = {'parameters' 1;'period' 1;'testfunctions' 0;'multipliers' 0;'current stepsize' 0};
    system.struct.numeric.HSN = {'parameters' 1;'period' 1;'testfunctions' 0;'multipliers' 0;'current stepsize' 0};
    system.struct.diagram = 'diagram';
    system.struct.parameters=[];
    system.struct.T=[];system.struct.eps0=[];system.struct.eps1=[];system.struct.extravec=[1 0 0]; system.struct.t=[]; system.struct.epsilon=[];
    system.struct.plot2='';system.struct.plot3='';system.struct.PRC='';system.struct.dPRC=''; 
     
         
%---------------------------------------------------------------------
function warning_box(stri1,stri2,handles)
global system
button = questdlg('System already exist! Do you want to continue? If you press yes to continue, you will overwrite the existing system',...
'System already exist','Yes','No','No');
dir=system.path_sys;
if strcmp(button,'Yes')
   system.struct.system=stri1;
   delete(stri2);
elseif strcmp(button,'No')
   set(handles.name_system,'String','');
end

%---------------------------------------------------------------------------
function string=make_init
global system;
string{1,1}='y0=[';
if (system.struct.dim>1)
    for i=1:(system.struct.dim-1)
        string{1,1}=strcat(string{1,1},'0,');
    end
end
string{1,1}=strcat(string{1,1},'0];');
string{2,1}=strcat('options = odeset(''Jacobian'',[],''JacobianP'',[],''Hessians'',[],''HessiansP'',[]);');   

%-----------------------------------------------------------------------------
function string=parsefile(file)
fid=fopen(file);
i=1;string=[];string{1,1}='empty';
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    string{i,1}='';
    while (~isempty(findstr(tline,'\'))||isempty(findstr(tline,']]')))
        tline=strrep(tline,'\','');
        if findstr(tline,'[[');
            tline=strrep(tline,'],','];');
            string{i,1}=tline;
        else
            tline=strrep(tline,'],','];');
            string{i,1}=strcat(string{i,1},tline);
        end
        tline=fgetl(fid);
    end
    tline=strrep(tline,'],','];');
    string{i,1}=strcat(string{i,1},tline);
    i=i+1;
end   
fclose(fid);
%--------------------------------------------------------------------------
%---
function line = symmat2line(symmat)
    [n,m] = size(symmat);
    line = '';
    for i = 1:n
        row = '';
        for j = 1:m
            if (j ~= 1)
                row = [row ' , ' char(symmat(i,j))];
            else
                row = char(symmat(i,j));
            end
        end
        if (i ~= 1)
            line = [line ' ; ' row];
        else
            line = row;
        end
    end
    line  = ['[ ' line ' ]'];
