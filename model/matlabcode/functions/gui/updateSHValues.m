function [ sh_weights_new ] = updateSHValues(sh_weights_old,sh_weights_new)

% Try to update sh_weights_new Matrix with Values stored in sh_weights_old

if (size(sh_weights_old,2) > size(sh_weights_new,2) && size(sh_weights_old,4) > size(sh_weights_new,4))
% loaded Value Matrix is bigger
sh_weights_new = sh_weights_old(1,1:size(sh_weights_new,2),1,1:size(sh_weights_new,4));
end

if (size(sh_weights_old,2) <= size(sh_weights_new,2) && size(sh_weights_old,4) <= size(sh_weights_new,4))
% loaded Value Matrix is smaller
sh_weights_new(1,1:size(sh_weights_old,2),1,1:size(sh_weights_old,4)) = sh_weights_old;
end

if (size(sh_weights_old,2) > size(sh_weights_new,2) && size(sh_weights_old,4) <= size(sh_weights_new,4))
% loaded Value Matrix is bigger and smaller
sh_weights_new(1,:,1,1:size(sh_weights_new,4)) = sh_weights_old(1,1:size(sh_weights_new,2),1,:);    
end

if (size(sh_weights_old,2) <= size(sh_weights_new,2) && size(sh_weights_old,4) > size(sh_weights_new,4))
% loaded Value Matrix is bigger and smaller
sh_weights_new(1,1:size(sh_weights_old,2),:) = sh_weights_old(1,:,1,1:size(sh_weights_new,4));
end

end