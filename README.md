# Detecting Tumours in MRI Brain Images

This is a source code for classifying MRI scans of brain images if it has 
a tumour, and segmenting out the tumour if any exists. 

## Files

1. tumour_detection.mlx     : Main Interface of programme
2. classification.mlx       : Experiment with different values for training 
                              tree 
3. Script files (.m)        : Functions used in the programme
4. Excel files (.xlsx)      : Values calculated using feature extraction to 
                              train classification model

## Dependencies

1. Image Processing Toolbox
2. Fuzzy Logic Toolbox

## Usage

1. Main Interface is in the file tumour_detection.mlx. For a cleaner 
   interface, hide the code. Only the output will be shown. 
2. Change the path to the input image in line 1 of the file.
4. To allow the script to find thresholds or other parameters automatically, 
   each of the parameters MUST be set to the following values:
   - threshold for skull stripping must be set to 0
   - levels for Otsu's thresholding must be set to 1
   - percentage for Watershed Algorithm must be set to 0
   The recommended number of clusters for Fuzzy C-Means Algorithm is 4. 
3. Run the script.
4. If any of the results of skull stripping, Otsu's thresholding, Fuzzy 
   C-Means algorithm and Watershed algorithm is not satisfactory, use the 
   slider to change the parameters to perhaps get a better results. 
   
## Contributors

Amber Song Xin Ying (29612330) - Morphological Operations, Feature Extraction & Classification
Ho Yuan Ai          (29566061) - Segmentation (Otsu, Fuzzy C-Means & Watershed) & Combination of results
Liow Gian Hao       (30666910) - Pre-processing, Skull stripping

## Special Thanks

Dr. Anuja and Ms. Najini for their supervision and help throughout the project. 
