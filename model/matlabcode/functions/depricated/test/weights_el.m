function weights_el(pc_weights,angles,mode)

% Plot by Azimuth
if mode == 1
    uaz = unique(angles(:,1));
    pc_max = 8;
    for l = 1:length(uaz)
        idx = find(angles(:,1) == uaz(l));
        figure(l);
        for pc = 1:pc_max
            subplot(4,2,pc);
    %         plot(angles(idx,2),squeeze(pc_weights(:,idx,pc))','.-');        
            boxplot(squeeze(pc_weights(:,idx,pc)),'labels',angles(idx,2))
            title(sprintf('PC: %d, Az: %.2f',pc,uaz(l)));
        end
    end
end

% Plot by Elevation
if mode == 2
    eaz = unique(angles(:,2));
    pc_max = 8;
    for l = 1:length(eaz)
        idx = find(angles(:,2) == eaz(l));
        figure(l);
        for pc = 1:pc_max
            subplot(4,2,pc);
    %         plot(angles(idx,2),squeeze(pc_weights(:,idx,pc))','.-');        
            boxplot(squeeze(pc_weights(:,idx,pc)),'labels',angles(idx,1));
            [p(l,pc),atab{l,pc}] = anova1(pc_weights(:,idx,pc),[],'off');
            title(sprintf('PC: %d, El: %.2f',pc,eaz(l)));
        end
    end
end

end

