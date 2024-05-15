function saveeps(varargin)
% 12/26/2018 Matlab gets the bounding box wrong when printing an image as an eps file. 
% How do I fix this? Use the following lines.
% set(gcf,'paperpositionmode','auto')
% print(gcf,'-depsc2','-loose','myImage.eps');
%
% switch from ucla sftp to dropbox, 9/12/2013
% saveeps(fid,epsfile)
% saveeps('tmp.png')	  
% saveeps('tmp.pdf')	  
% saveeps('tmp.eps')	  
% saveeps('tmp.png_'), send tmp.png to sftp to be viewed online	 
epstopdf='~/myscript/myeps2pdf ';
epstopdf='~/Dropbox/setup/cljhome/myscript/myeps2pdf ';

verinfo=version();
ind=find(verinfo=='R');
vernum=str2num(verinfo(ind+[1:4]));
% if vernum>2012
%     saveeps2015(varargin{:});
% end


if nargin==0
    fid=gcf;
    epsfile='';
end
if nargin==1
    fid=gcf;
    epsfile=varargin{1};
end

if nargin>=2
    fid=varargin{1};
    epsfile=varargin{2};
end




if strcmp(epsfile,'_')
	epsfile='tmp.png_';
end

sftpmode=0;
finishmode=1;
savefig=0;

if length(epsfile)>0
    if epsfile(end)=='_'
        sftpmode=1;
        epsfile(end)='';
    elseif epsfile(end)=='$'
        finishmode=0;
        epsfile(end)='';
    elseif epsfile(end)=='&'
	  savefig=1;
        epsfile(end)='';
    else
    end
end

% hoststr=uname();
% if strexist(hoststr,'wavea') | strexist(hoststr,'waveb') | strexist(hoststr,'wavec')
%     finishmode=0; % turn off finishing mode
% end

    if finishmode==1
        % change all font sizes in a figure
        set(fid, 'PaperPositionMode', 'auto');
        set(findall(fid, 'Type','text'), 'FontSize', 15)
        %set(findall(fid, 'Type','axes'), 'FontSize', 15);
        set(findall(fid, 'Type','axes'), 'FontSize', 15,'tickdir','out','xminortick','on','yminortick','on')
    end
    
if nargin>2
    for i=3:nargin
        % {'line','linewidth',2}
        %set(findall(gcf, 'Type','line'), 'linewidth', 2)
        thisvar=varargin{i};
        set(findall(gcf, 'Type',thisvar{1}), thisvar{2}, thisvar{3})
    end
end%

%
%rgb2cm_


if 1
    set(gcf,'color','w')
    set(findall(fid, 'Type','axes'), 'FontSize', 15,'tickdir','out','xminortick','on','yminortick','on')

end



% set PaperPositionMode to auto so that the exported figure looks like it does on the screen. 
if length(epsfile)>0
    disp(epsfile)

    if(strcmp(epsfile([-3:0]+end),'.eps'))
        epsfile2=[epsfile(1:end-4),'.pdf'];
%         %print(fid,'-depsc','-painter','-adobecset',epsfile)
%         %print(fid,'-depsc','-painters',epsfile); %fixeps(epsfile); % epsc color eps
%         print(fid,'-depsc2','-loose',epsfile); %fixeps(epsfile); % epsc color eps
%         %system(['myeps2pdf ',epsfile])
%         system([epstopdf,epsfile])
        export_fig(fid,epsfile)
    elseif(strcmp(epsfile([-3:0]+end),'.pdf'))
        epsfile2=[epsfile(1:end-4),'.eps'];
%         %print(fid,'-depsc','-painter','-adobecset',[epsfile2])
%         print(fid,'-depsc','-loose',[epsfile2]); %fixeps(epsfile);
%         %print(fid,'-depsc2',epsfile); %fixeps(epsfile); % epsc color eps
%         system([epstopdf,epsfile2])
%         %system(['rm ',epsfile2]) % delete the eps file
        export_fig(fid,epsfile2)
        export_fig(fid,epsfile)
    elseif(strcmp(epsfile([-3:0]+end),'.png'))
        if finishmode==1
        % to avoid axis tick labels to be changed 
        %set(findall(fid, 'Type','axes'), 'Ytickmode', 'manual')
        %set(findall(fid, 'Type','axes'), 'Xtickmode', 'manual')
        end
        saveas(fid,epsfile,'png')
        %saveas(fid,'-zbutter',epsfile,'png')
    else
        saveas(fid,epsfile)
        %  nothing is done here
    end
    %if(sftpmode),system(['mysftp "put ',epsfile,'"']);,end; 
    % using ucla sftp web function
    %
    if(sftpmode),system(['cp -f ',epsfile,' ~/Dropbox/tmp/']);,end; % switch to Dropbox, 9/12/2013

    if (savefig)
		ind=find(epsfile=='.');
		figfile=[epsfile(1:ind(en)),'.fig'];
		saveas(gcf,figfile);
    end
end



return
% affect xylabel, title, text, legend text
set(findall(gcf, 'Type','text'), 'FontSize', 15,'FontWeight','Normal')
% affect xytick, legend, colorbar text, but not title, xylabel

%set(findall(gcf, 'Type','axes'), 'FontSize', 15,'FontWeight','Normal')
set(findall(gcf, 'Type','axes'), 'FontSize', 15,'FontWeight','Normal','tickdir','out')





function rgb2cm_
% rgb2cm - Clean up colour mapping in patches to allow Painter's mode
%
% Painter's mode rendering is required for copying a figure to the
% clipboard as an EMF (vector format) or printing to vector-format files
% such as PDF and EPS. However, if the colours of any patches in your 
% figure are represented using CData and an RGB colour code, these will not
% show in the copied figure. You may also get a warning like:
% Warning: RGB color data not yet supported in Painter's mode 
%
% One solution is to change these specific patches to use an index into the
% colormap. That's what this script does. For each patch using RGB, it adds
% those colours to the colormap and changes the patch to use a colormap
% index.
%
% Robbie Andrew, March 2012

patches = findall(gcf,'Type','patch') ;

cm = colormap ;
j=size(cm,1)+1 ;
for i=1:numel(patches)
    set(patches(i),'CDataMapping','direct')
    c = get(patches(i),'FaceColor') ;
    if strcmpi('flat',c)
        c = get(patches(i),'FaceVertexCData') ;
        if size(c,2)>1
            cm = [cm; c] ;
            n = size(c,1) ;
            set(patches(i),'FaceVertexCData',j+(0:n-1)')
            j=j+n ;
        end
    end
end

colormap(cm)
	  

%18 Sep 2012
%Robbie Andrew
%This function works with *patches*. If you have the same problem with lines plotted with markers, simply edit the code and replace 'FaceColor' with 'MarkerFaceColor'. Thanks to Håkon for the tip.
	  



function saveeps2015(varargin)
% update to be compatible with 2015 version or above
%%












function fixeps(filename)
fid = fopen(filename,'r+');
k=0;
while k <2                                                  % 2 locations to replace.
    tline = fgetl(fid);                                     % get one line text
    stridx=strfind(tline,'Box:');
	if isempty(stridx)==0
        len=length(tline)                                   % the original line length
		bb=sscanf(tline(stridx+4:end),'%i');                % read the numbers
		bbstr=sprintf('%g %g %g %g',bb);                    % write bb numbers to string
        tline=tline(1:stridx+3)                             % keep the "%%(page)boundingbox" string (with starting '%%')
		spaces(1:len-length(tline)-length(bbstr)-1)=' ';    % add trailing spaces as to overwrite old line completely
		tline=[tline ' ' bbstr spaces];                     % concate numbers and blank spaces to "%%(page)boundingbox"

        fseek(fid,-len-2,'cof');                            % before using fprintf search to correct position
		count = fprintf(fid,'%s',tline)
        fseek(fid,2,'cof');                                 % seek to beginning of line (for windows text file) on
                                                            % for linux: change '2' to '1' I think
        k=k+1;
	end
end
fclose(fid);
