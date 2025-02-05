# Postelsia Collapse

*Short synopsis*

------------------------------------------------------------------------

There are 5 R scripts associated with this repository run all console and data preparation, data cleaning, analysis, and visualization steps:

-   **00_Packages.R** loads every package that is needed in following scripts. After running this script, all following scripts can be run independently.

-   **01_Postelsia.R** conducts analyses and visualizations with data from MARINe *Postelsia palmaeformis* plots/transects.

-   **02_Repeat_Photos.R** conducts analyses and visualizations with extracted data from the repeated panoramic photos.

-   **03_Stars.R** conducts analyses and visualizations with long-term monitoring data from MARINe sea star plots.

-   **04_Heatwave.R** analyzes water temperature data from in-situ HOBO loggers to quantify, describe, and visualize local climatology and marine heatwaves.

*Note:* *Due to the conservation status of Postelsia palmaeformis, we removed all site-specific metadata from all publicly-available data and code. Because of this, R scripts to produce the map figure (Figure XB) are not published in this repository*.

------------------------------------------------------------------------

### Directory Information

#### Folder "[data](https://github.com/fgerraty/Postelsia_Collapse/tree/main/data)" houses raw and processed data files associated with this repository.

See "[data dictionary](https://github.com/fgerraty/Postelsia_Collapse/blob/main/data/README.md)" for details on data files and associated metadata

#### Folder "[output](https://github.com/fgerraty/Postelsia_Collapse/tree/main/output)" houses the following folders and files

-   Folder [**main_figures**](https://github.com/fgerraty/Postelsia_Collapse/tree/main/output/main_figures) containing figures in manuscript main text:

    -   Figure_1.png

    -   Figure_2.png

    -   Figure_3.png

-   Folder [**supplemental_figures**](https://github.com/fgerraty/Postelsia_Collapse/tree/main/output/supplemental_figures) containing figures in manuscript supplemental information:

    -   etc.

-   Folder [**extra_figures**](https://github.com/fgerraty/Postelsia_Collapse/tree/main/output/extra_figures) containing supporting figures not included in manuscript main text or supplemental information.

    -   Folder "map", containing all components of the map portion of Figure X.

    -   etc.
