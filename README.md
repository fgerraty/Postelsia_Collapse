# Marine heatwave and keystone predator loss drive broad-scale decline and hinder recovery of a rocky intertidal kelp

FD Gerraty, K Ammann, MA Douglas, M George, D Lohse, CM Miner, PT Raimondi. (2025) Marine heatwave and keystone predator loss drive broad-scale decline and hinder recovery of a rocky intertidal kelp. *In Review*

We examined the direct and indirect effects of the 2014-2016 northeast Pacific marine heatwave (MHW) and the synergistic sea star wasting disease outbreak on the abundance, persistence, and recovery of the sea palm, *Postelsia palmaeformis*. To do so, we leveraged long-term rocky intertidal community monitoring data collected for over two decades at seventeen sites spanning most of the southern portion of the kelp's geographic range. We found that *P. palmaeformis* populations declined during the 2014-2016 MHW, likely due to acute thermal stress. In tandem, we found that ochre star (*Pisaster ochraceus*) loss led to mussel bed expansion, indirectly hindering *P. palmaeformis* recovery. Our results show that these synergistic disturbances acted as a "one-two punch" to drive persistent, broad-scale *P. palmaeformis* declines.

------------------------------------------------------------------------

There are 5 R scripts associated with this repository run all console and data preparation, data cleaning, analysis, and visualization steps:

-   **00_Packages.R** loads every package that is needed in following scripts. After running this script, all following scripts can be run independently.

-   **01_Heatwave.R** analyzes water temperature data from in-situ HOBO loggers to quantify, describe, and visualize local climatology and marine heatwaves.

-   **02_Postelsia.R** conducts analyses and visualizations with data from MARINe *Postelsia palmaeformis* transects.

-   **03_Repeat_Photos.R** conducts analyses and visualizations with extracted data from the repeated panoramic photos.

-   **04_Stars.R** conducts analyses and visualizations with long-term monitoring data from MARINe sea star plots.

-   **05_Mussels.R** conducts analyses and visualizations of mussel dynamics with long-term monitoring data from MARINe Coastal Biodiversity Survey data.

*Note:* *Due to the conservation status of Postelsia palmaeformis, we removed all site-specific metadata from all publicly-available data and code. Because of this, R scripts to produce the map figure (Figure 2B) are not published in this repository*.

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
