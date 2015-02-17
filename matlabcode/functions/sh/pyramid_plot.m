function pyramid_plot(sh_weights,order)

% Plot Energy in the Different Spherical Harmonics
sh_weights = abs(sh_weights);
max_w = ceil(max(max(sh_weights)));
sh_weights = 20*log10(sh_weights/max_w);
max_w = ceil(max(max(sh_weights)));
min_w = floor(min(min(sh_weights)));
max_id = (order + 1)^2;
% shw = permute(reshape(shw,[max_id 512 50]),[1 3 2]);

size(sh_weights)
shw = permute(reshape(sh_weights,max_id, 512, []),[1 3 2]);

msw = squeeze(mean(shw,2));
sdsw = squeeze(std(shw,0,2));

for sho = 0:order
    idx = ((sho-1+1)^2) + (1:(2*sho+1));
    x = -sho:sho;
    y =  repmat(-sho,[length(x) 1]);
    for pc = 1:5
        figure(pc);hold on;
        for k = 1:length(x)
%             disp(sprintf('%.3f, %.3f',(msw(idx(k),pc) - min_w)/(max_w-min_w),(msw(idx(k),pc))))
            clr = repmat((msw(idx(k),pc) - min_w)/(max_w-min_w),[1 3]);
%             disp(clr);
            plot(x(k),y(k),'s','MarkerSize',30,'MarkerFaceColor',clr,'MarkeredgeColor',clr);    
%             if length(x) == 1
%                 clr = repmat((msw(pc) - min_w)/(max_w-min_w),[1 3]);
%                 plot(x(k),y(k),'s','MarkerSize',30,'MarkerFaceColor',clr,'MarkeredgeColor',clr);    
%             else
%                 clr = repmat((msw(k,pc) - min_w)/(max_w-min_w),[1 3]);
%                 plot(x(k),y(k),'s','MarkerSize',30,'MarkerFaceColor',clr,'MarkeredgeColor',clr);                
%             end
        end
    end
%     bar(msw(:,1:5)');
end

end

