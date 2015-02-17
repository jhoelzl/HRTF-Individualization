function [y,h] = test_sub(db,mode,test_sub)

% db
%mode = pcw, pcw2sh
% Test PCWs of test_sub

db_file = sprintf( '../matlabdata/model/%s_%s.mat',db,mode);

if (exist(db_file,'file') == 2)
    load(db_file);
else
    model = core_calc(db,mode);
    save(db_file,'model','-v7.3');
end

h = 1;

sh = 1;

y = prctile(model.pcws_res,[2.5 25 50 95]);
figure(20)
clf;
plot(squeeze(y(:,1,1,1:5)))

figure(10)
clf;
for pc=1:4
   % for pos=1:size(model.pcws_res,2)
    
    % PCWs
    if (strcmp(mode,'pcw') == 1)
    subplot(2,2,pc)
    hist(model.pcws_res(:,1,1,pc))
    hold on
    test_pcw = squeeze(model.pcws_res(test_sub,1,1,pc));
    line([test_pcw test_pcw],[0 10],'Color',[1 0 0]) 
    %sprintf('PC',pc)
    %h(pos,pc)= lillietest(squeeze(model.pcws_res(:,pos,1,pc)));
    end
    
    % SHWs
    if (strcmp(mode,'pcw2sh') == 1)
    subplot(2,2,pc)
    hist(model.weight_model.sh_weights(:,sh,1,pc))
    hold on
    test_shw = squeeze(model.weight_model.sh_weights(test_sub,sh,1,pc));
    line([test_shw test_shw],[0 10],'Color',[1 0 0])     
    end
    
  %  end

end