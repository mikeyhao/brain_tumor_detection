function [output, percentage] = auto_watershed_algo(ss_img, verify_mask, mask)
    % threshold controls
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
    percentage = 80;

    stop_looping = false;
    while true
        percentage = percentage - 1;
        if percentage < 10
            % relax conditions by adjusting threshold 
            percentage = 80;
            center_perc = center_perc - 0.01;
            x_top = brain_box(1,1) + brain_box(1,3)*((1-center_perc)/2);
            x_bottom = brain_box(1,1) + brain_box(1,3)*((1+center_perc)/2);
            y_left = brain_box(1,2) + brain_box(1,4)*((1-center_perc)/2);
            y_right = brain_box(1,2) + brain_box(1,4)*((1+center_perc)/2);
            axis_diff_threshold = axis_diff_threshold + 0.01;
            % if tried all and still cannot find, fix percentage to 30 and
            % output
            if center_perc == double(0)
                percentage = 31; 
                stop_looping = true;
            end
            continue
        end
        no_minima = imhmin(grad_M, percentage);
        L = watershed(no_minima, 8);
        L(~mask) = 0;
        class_name = class(L);
        selected_L = L .* cast(verify_mask, class_name);

        stats = regionprops(selected_L, 'EquivDiameter', 'MajorAxisLength', ...
            'MinorAxisLength', 'Centroid');
        diameter = [stats.EquivDiameter];
        real_diameter = [regionprops(L, 'EquivDiameter').EquivDiameter];
        centroids = [stats.Centroid];
        centroids = reshape(centroids, 2, length(centroids)/2);
        perc_diff_axis_length = ([stats.MajorAxisLength] - [stats.MinorAxisLength]) ./...
            [stats.MajorAxisLength];
        % must be outside of the center & shape not too long
        possibleIndices = find((centroids(1,:) < x_top | ...
                centroids(1,:) > x_bottom | ...
                centroids(2,:) < y_left | ...
                centroids(2,:) > y_right) & ...
                perc_diff_axis_length < axis_diff_threshold);
        [~, sortIndices] = sort(diameter, "descend");
        if ~isempty(sortIndices) && any(possibleIndices == sortIndices(1)) && real_diameter(sortIndices(1)) < brain_diameter*0.3
            possibleIndices = intersect(possibleIndices, ...
                find(real_diameter < brain_diameter*0.3));
            break
        end
        if stop_looping
            break
        end
    end
    output = ismember(L, possibleIndices);
end