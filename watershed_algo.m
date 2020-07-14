function [output] = watershed_algo(ss_img, verify_mask, mask, percentage)
    center_perc = 0.4;
    axis_diff_threshold = 0.5;
    
    whole_brain = regionprops(double(mask), 'BoundingBox', 'EquivDiameter');
    brain_box = whole_brain.BoundingBox;
    x_top = brain_box(1,1) + brain_box(1,3)*((1-center_perc)/2);
    x_bottom = brain_box(1,1) + brain_box(1,3)*((1+center_perc)/2);
    y_left = brain_box(1,2) + brain_box(1,4)*((1-center_perc)/2);
    y_right = brain_box(1,2) + brain_box(1,4)*((1+center_perc)/2);
    brain_diameter = whole_brain.EquivDiameter(1);
    
    comp = imcomplement(ss_img);
    double_comp = double(comp);
    [grad_M, ~] = imgradient(double_comp);

    no_minima = imhmin(grad_M, percentage);
    L = watershed(no_minima, 8);
    L(~mask) = 0;
    class_name = class(L);
    selected_L = L .* cast(verify_mask, class_name);

    stats = regionprops(selected_L, 'EquivDiameter', 'MajorAxisLength', ...
        'MinorAxisLength', 'Centroid');
    real_diameter = [regionprops(L, 'EquivDiameter').EquivDiameter];
    centroids = [stats.Centroid];
    centroids = reshape(centroids, 2, length(centroids)/2);
    perc_diff_axis_length = ([stats.MajorAxisLength] - [stats.MinorAxisLength]) ./...
        [stats.MajorAxisLength];
    % must be outside of the center 15% of the width and length of the
    % bounding box of brain mask & shape not too long
    possibleIndices = find((centroids(1,:) < x_top | ...
            centroids(1,:) > x_bottom | ...
            centroids(2,:) < y_left | ...
            centroids(2,:) > y_right) & ...
            perc_diff_axis_length < axis_diff_threshold);
    possibleIndices = intersect(possibleIndices, ...
        find(real_diameter < brain_diameter*0.3));
    output = ismember(L, possibleIndices);
end