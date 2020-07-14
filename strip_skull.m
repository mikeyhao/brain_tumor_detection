function [label] = strip_skull(img, threshold)
    ss_bin = imbinarize(img, threshold);
    % perform opening to remove any thin lines between skull and brain
    se = strel("disk", 5);
    ss_bin = imopen(ss_bin, se);
    [label,~] = bwlabel(ss_bin);
    
    % Find the largest connected components
    measurements = regionprops(label, 'Area');
    areas = [measurements.Area];
    [~, sortIndices] = sort(areas, "descend");
    frequent_label = sortIndices(1);
    label = label == frequent_label;    
end