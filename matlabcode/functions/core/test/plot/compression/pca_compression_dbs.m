function pca_compression_dbs()

% PCA compression efficiency for different input signal representations and
% databases

dbs = {'ari','cipic','ircam'};
X = zeros(length(dbs),4,200);

% config:
ears = 1;
input_struct = 1;
ear_mode = 1;
smooth = 1;
posmode =1;
bpmode = 1;
submode = 1;
for db=1:length(dbs)

    % Load Error File
    error_data = sprintf('../matlabdata/test_pca/variance_pca_%s_leftear.mat',dbs{db});
    load(error_data,'pcs_variance','conf');

    % Show conf
    conf
    for input_mode=1:4
    X(db,input_mode,:) = squeeze(pcs_variance(submode,bpmode,posmode,ears,input_mode,input_struct,ear_mode,smooth,:));
    end
    
end


figure(3)
clf;

mark= {'-','--',':'};
col = {'k','b','r',[0 .7 0]};
figure(3)

for inp=1:size(X,2)
    for db=1:size(X,1)
    
    plot(squeeze(X(db,inp,:)),'Color',col{inp},'LineStyle',mark{db},'LineWidth',1.3);
    hold on

    end
    
    if(inp == 1)
    legend('ARI','CIPIC','IRCAM','Location','SouthEast')

    end
end


annotation('textbox',[0.64 0.51 0.1 0.1],'String','HRIR','BackgroundColor',col{1},'FontSize',12, 'Color','w','LineWidth',0)
annotation('textbox',[0.64 0.45 0.1 0.1],'String','Min-phase HRIR','BackgroundColor',col{2},'FontSize',12, 'Color','w','LineWidth',0)
annotation('textbox',[0.64 0.39 0.1 0.1],'String','DTF lin magnitude','BackgroundColor',col{3},'FontSize',12, 'Color','w','LineWidth',0)
annotation('textbox',[0.64 0.33 0.1 0.1],'String','DTF log magnitude','BackgroundColor',col{4},'FontSize',12, 'Color','w','LineWidth',0)


xlim([0 50])
ylim([60 100])
%legend('ARI','CIPIC','IRCAM','Location','best') 
title('PCA compression efficiency')
xlabel('PC number')
ylabel('percent variance')
grid on

% Linie 90%
a = ones(110,1)*90;
hold on
plot(a,'k-.')

%Save
set(3,'paperunits','centimeters','paperposition',[1 2 15 10])
saveas(3,sprintf('../thesis/images/compression/pca_structur/pca_compression_dbs_inp%i_em%i',input_struct,ear_mode),'epsc');
end

