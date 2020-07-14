function [output] = otsu_algo(I, no_levels)
    levels = multithresh(I, no_levels);
    output = I >= levels(2);
end