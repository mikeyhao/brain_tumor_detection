function [output] = combine_results(otsu_img, watershed_img, fuzzy_img)
    SE = strel('disk',1);
    intensity_combined = bitand(otsu_img, fuzzy_img);
    strong_p = intensity_combined & watershed_img;
    weak_p = (intensity_combined | watershed_img) - strong_p;
    weak_p = imerode(weak_p, SE);
    pre_hys = 255*uint8(strong_p) + 100*uint8(weak_p);
    post_hys = hysteresis(pre_hys, 100, 255);
    output = logical(post_hys); 
    SE = strel('disk',4);
    output = imdilate(output, SE);
    output = imfill(output, "holes");
    [m,n,~] = size(output);
    threshold = 0.004;
    tumour_count = 0;
    while tumour_count == 0
        threshold = threshold + 0.001;
        new_output = bwareaopen(output, floor(m*n*threshold));    
        [blobs_label, tumour_count] = bwlabel(new_output);
    end
    output = new_output;
    blobs_props = regionprops(blobs_label, 'Circularity', 'Solidity');
    blobs_circularity = [blobs_props.Circularity];
    blobs_solidity = [blobs_props.Solidity];
    circular_blobs = find((blobs_circularity <= 1 & ...
        blobs_circularity > 0.2) | ...
        blobs_solidity > 0.628); % pi/5, pi/4 is for perfect circle
    if ~isempty(circular_blobs)
        output = ismember(blobs_label, circular_blobs);    
    end
    output = logical(output);
end