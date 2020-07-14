function [output, no_levels] = auto_otsu_algo(I, mask)
    % change no_levels until intra-class variance is minimum
    % as proposed by Kapoor & Thakur (2017)
    % score is also penalized by the difference of areas, so that segmented
    % (tumour) area should be smaller than outside of tumour 
    vars = zeros(1, 9);
    vars_out = zeros(1, 9);
    areas = zeros(1,9);
    areas_out = zeros(1,9);
    warning('off','all'); % suppress warnings

    for no_levels = 2:10
        levels = multithresh(I, no_levels);
        otsu_img = I >= levels(2);
        vars(no_levels-1) = var(single(I(otsu_img)));
        out_mask = logical(imsubtract(mask, otsu_img));
        vars_out(no_levels-1) = var(single(I(out_mask)));

        areas(no_levels-1) = regionprops(double(otsu_img), 'Area').Area;
        if all(out_mask == 0)
            areas_out(no_levels-1) = 0;
        else
            areas_out(no_levels-1)  = regionprops(double(out_mask), 'Area').Area;
        end
    end

    warning('on', 'all');
    total_score = vars + vars_out + areas - areas_out;

    [~,no_levels] = min(total_score);
    no_levels = no_levels + 1;
    levels = multithresh(I, no_levels);
    output = I >= levels(2);
end