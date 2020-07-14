function [output] = fuzzy_algo(ss_img, clusters, mask)
    [~, U] = fcm(double(ss_img(:)), clusters, [NaN NaN NaN false]);
    [m,n,~] = size(ss_img);
    % U is a matrix which has clusters number of rows and one column for
    % each data point
    maxU = max(U);
    L = zeros(m,n);
    for i = 1:clusters
        indices = U(i,:) == maxU;
        L(indices) = i;
    end
    L(~mask) = 0;
    
    measurements = regionprops(L, ss_img, 'MeanIntensity');
    intensities = [measurements.MeanIntensity];
    [~, sortIndices] = sort(intensities, 'descend');
    output = ismember(L, sortIndices(1));
end