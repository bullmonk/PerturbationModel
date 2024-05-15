function setfigpos(f,pos,spl)
set(f,'Units','inches')
%set(f,'Units','centimeters')
ratio=0.76;
pos1=pos/ratio;
set(f,'position',pos1)

% set(gcf, 'PaperUnits', 'inches');
% set(gcf, 'PaperSize', [6.25 7.5]);
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperPosition', [0 0 6.25 7.5]);
% 
% The trick is to ask Matlab to use the "painters" renderer. It does not support transparency, but at least you're guaranteed vector graphics output:
% 
% set(gcf, 'renderer', 'painters');
% 
% Finally, just for the sake of completeness, you might want to actually generate your output file:
% 
% print(gcf, '-dpdf', 'my-figure.pdf');
% print(gcf, '-dpng', 'my-figure.png');
% print(gcf, '-depsc2', 'my-figure.eps');

set(f, 'PaperUnits', 'inches');
set(f, 'PaperSize', [pos(3) pos(4)]);
set(f, 'PaperPositionMode', 'manual');
set(f, 'PaperPosition', [0 0 pos(3) pos(4)]);

if(nargin>2)
    for isp=1:spl(1)*spl(2)
        h=subplot(spl(1),spl(2),isp);
        pos=get(gca,'position'); 
        set(gca,'position',pos); % enforce the plot position
        setax;
    end
end
