function [DATA_PCA,MEAN_SUB,subjects_list,idx ] = remove_outlier(DATA_PCA,MEAN_SUB,subjects_list,weights,plot,pca_mode )
[~, idx] = deleteoutliers(weights(:,1), 0.02);
        
        if (size(idx,1) > 0)

        subplot(1,4,plot)
        hist(weights(:,1),20)
        title(sprintf('%i PCWs 1',length(weights(:,1))))
        xlabel(sprintf('Detected %i outlier',size(idx,1)))
        end
            
        for r=1:size(idx,1)
    
            text = sprintf('Found outlier with Index %i',idx(r));
            disp(text)

            
            hold on
            line([weights(idx(r),1) weights(idx(r),1)],get(gca,'Ylim'),'Color',[1 0 0]) 
            
            DATA_PCA(idx(r),:)=[];
            subjects_list(idx(r)) = [];
            
            
            if (pca_mode == 1)
            MEAN_SUB(idx(r),:,:,:) = [];
            end
        
        end
        

%subjects = subjects - size(idx,1);

end
