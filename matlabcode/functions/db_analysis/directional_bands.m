function directional_bands(mode)

% Plot Gantt Diagram of directional bands for different authors

% Blauert 1: front/back: directional bands
% Blauert 2: positive / negative boosted bands

authors = {'So et al.','Tan and Gan','Myers','Blauert (directional bands)  ','Blauert (boosted bands)  '};

if (strcmp(mode,'front'))
    % Front Perception
    bands{1} = {[170 680 1], [680 2400 -1], [2400 6300 1], [6300 10300 -1], [10300 14900 -1], [14900 22000 1]};
    bands{2} = {[225 680 1], [680 2000 -1], [2000 6300 1], [6300 10900 -1], [10900 22000 1]};
    bands{3} = {[280 682 1], [682 2069 -1], [2069 6279 1], [6279 22050 -1]};
    bands{4} = {[280 560 1], [2900 5800 1]};
    bands{5} = {[150 540 1], [1900 2900 1],[3600 5800 1]};

else
    % Back Perception
    bands{1} = {[170 680 -1], [680 2400 1], [2400 6300 -1], [6300 10300 1], [10300 14900 1], [14900 22000 -1]};
    bands{2} = {[225 680 -1], [680 2000 1], [2000 6300 -1], [6300 10900 1], [10900 22000 -1]};
    bands{3} = {[280 682 -1], [682 2069 1], [2069 6279 -1], [6279 22050 1]};
    bands{4} = {[720 1800 1], [10300 14900 1]};
    bands{5} = {[700 1700 -1], [7400 11100 -1]};
end

% Plot
figure(5)
clf;

for i=1:length(bands)
    for bd = 1:length(bands{i})
    
    bd1 = bands{i};
    bd2 = bd1{bd};
        

       range = bd2(2)-bd2(1);
       if (bd2(3) == 1)
           clr = [1 0.5 0.2];
       else
           clr = 'y';
       end
       
       rectangle('Position',[bd2(1),i+0.3,range,1],'Curvature',[0,0],'LineWidth',0.5,'LineStyle','-','Facecolor',clr)      
       hold on
       
    end
    
    text(800,i+0.8,authors{i},'BackgroundColor',[.7 .9 .7])
    
end

set(gca,'XScale','log')
title(sprintf('Directional Bands for %s Perception',mode))
grid on
xlabel('frequency [Hz]')
ylabel('authors')
set(gca,'ytick',[],'xlim',[0 22050]) 
xlim([100 20000])

set(5,'paperunits','centimeters','paperposition',[1 1 12 8])
saveas(5,sprintf('../thesis/images/directional_bands/gantt_%s',mode),'epsc');


end