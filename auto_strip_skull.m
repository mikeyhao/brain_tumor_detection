function [label, threshold] = auto_strip_skull(img, starting_threshold)
    threshold = starting_threshold;
    center_perc = 0.92;
    contract_perc = 0.04;
    area_perc = 0.8;
    
    ss_bin = imbinarize(img, threshold);
    ori_measurement = regionprops(double(ss_bin), 'BoundingBox', 'Area');
    ori_bounding_box = ori_measurement.BoundingBox;
    ori_width = ori_bounding_box(1,3);
    ori_height = ori_bounding_box(1,4);
    ori_area = ori_measurement.Area; 

    box_not_contracted = true;
    area_too_small = false;

    % if frequent_label is one then the region is the most top left pixel
    % which is labelled, which would probably mean the skull is still in
    % the mask. box_not_contracted is to check if the bounding box of the 
    % region is contracted to a certain extent. 
    while box_not_contracted && ~area_too_small
        threshold = threshold + 0.01;
        ss_bin = imbinarize(img, threshold);
        % perform opening to remove any thin lines between skull and brain
        se = strel("disk", 5);
        ss_bin = imopen(ss_bin, se);
        [label,~] = bwlabel(ss_bin);
        
        % Find the largest connected components
        measurements = regionprops(label, 'Area');
        areas = [measurements.Area];
        [sorted_area, sortIndices] = sort(areas, "descend");
        if isempty(sortIndices)
            threshold = starting_threshold;
            center_perc = center_perc + 0.02;
            contract_perc = contract_perc - 0.01;
            continue
        end
        area = sorted_area(1);
        frequent_label = sortIndices(1);
        temp = ismember(label, frequent_label);
        measurements = regionprops(double(temp), 'BoundingBox');
        bounding_box = measurements.BoundingBox;
        box_not_contracted = ((bounding_box(1,1) < (ori_bounding_box(1,1) + ori_width*contract_perc) && ...
            bounding_box(1,2) < (ori_bounding_box(1,2) + ori_height*contract_perc)) || ...
            (bounding_box(1,3) > (ori_width*center_perc) && ...
            bounding_box(1,4) > (ori_height*center_perc)));
        area_too_small = area < (ori_area*area_perc);
    end  
    label = label == frequent_label;
end