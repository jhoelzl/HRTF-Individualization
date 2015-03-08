function pca_compression_dbs_paper()

% PCA compression efficiency for different input signal representations and
% databases

dbs = {'ari','cipic','ircam'};
X = zeros(length(dbs),4,200);

% config: specify data in matrix pcs_variance;
ears = 3;
input_struct = 2;
ear_mode = 2;
smooth = 1;
posmode =1;
bpmode = 1;
submode = 1;
for db=1:length(dbs)

    % Load Error File
    error_data = sprintf('../matlabdata/test_pca/variance_pca_%s.mat',dbs{db});
    load(error_data,'pcs_variance','conf');

    % Show conf of computation
    conf
    for input_mode=1:4
    X(db,input_mode,:) = squeeze(pcs_variance(submode,bpmode,posmode,ears,input_mode,input_struct,ear_mode,smooth,:));
    end
    
end


figure(3)
clf;

%mark= {':','--','-','-.'};
mark= {'^','o','*','+'};
col = {'k','r',[0 .7 0],'g'};
figure(3)

xax = [1:9,10:2:19,20:3:50];

for db=1:size(X,1)
    for inp=1:size(X,2)
    plot(xax,squeeze(X(db,inp,xax)),'Color',col{db},'Marker',mark{inp},'LineStyle',':','Linewidth',2);
    hold on
    end
    
    if(db == 1) 
    legend('HRIR','Minimum-phase HRIR','DTF lin magnitude','DTF log magnitude','Location','SouthEast')
    end
end

annotation('textbox',[0.7 0.51 0.1 0.1],'String','ARI','BackgroundColor',col{1},'FontSize',14, 'Color','w','LineWidth',0)
annotation('textbox',[0.7 0.45 0.1 0.1],'String','CIPIC','BackgroundColor',col{2},'FontSize',14, 'Color','w','LineWidth',0)
annotation('textbox',[0.7 0.39 0.1 0.1],'String','IRCAM','BackgroundColor',col{3},'FontSize',14, 'Color','w','LineWidth',0)

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
%set(3,'paperunits','centimeters','paperposition',[1 2 15 10])
set(3,'paperunits','centimeters','paperposition',[1 2 20 13])
saveas(3,sprintf('../paper/dafx14/v1/images/pca_compression_dbs3_inp%i_em%i',input_struct,ear_mode),'epsc');
%print(3,'-depsc',sprintf('../paper/dafx14/v1/images/pca_compression_dbs3_inp%i_em%i',input_struct,ear_mode));

end

