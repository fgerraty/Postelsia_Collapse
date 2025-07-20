# Marine heatwave and keystone predator loss drive broad-scale decline and hinder recovery of a rocky intertidal kelp

FD Gerraty, K Ammann, MA Douglas, M George, DP Lohse, CM Miner, PT Raimondi. (2025) Marine heatwave and keystone predator loss drive broad-scale decline and hinder recovery of a rocky intertidal kelp. *In Review*

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16241083.svg)](https://doi.org/10.5281/zenodo.16241083)

We examined the direct and indirect effects of the 2014-2016 northeast Pacific marine heatwave (MHW) and the synergistic sea star wasting disease outbreak on the abundance, persistence, and recovery of the sea palm, *Postelsia palmaeformis*. To do so, we leveraged long-term rocky intertidal community monitoring data collected for over two decades at seventeen sites spanning most of the southern portion of the kelp's geographic range. We found that *Postelsia* populations declined during the 2014-2016 MHW, likely due to acute thermal stress. In tandem, we found that the functional loss of ochre stars (*Pisaster ochraceus*) led to mussel bed expansion, indirectly hindering *Postelsia* recoveries. Our results show that these synergistic disturbances acted as a "one-two punch" to drive persistent, broad-scale *Postelsia* declines.

------------------------------------------------------------------------

There are 6 R scripts associated with this repository run all console and data preparation, data cleaning, analysis, and visualization steps:

-   **00_Packages.R** loads every package that is needed in following scripts. After running this script, all following scripts can be run independently.

-   **01_Heatwave.R** analyzes water temperature data from in-situ HOBO loggers to quantify, describe, and visualize local climatology and marine heatwaves.

-   **02_Postelsia.R** conducts analyses and visualizations with data from MARINe *Postelsia palmaeformis* transects.

-   **03_Repeat_Photos.R** conducts analyses and visualizations with extracted data from the repeated panoramic photos.

-   **04_Stars.R** conducts analyses and visualizations with long-term monitoring data from MARINe sea star plots.

-   **05_Mussels.R** conducts analyses and visualizations of mussel dynamics with long-term monitoring data from MARINe Coastal Biodiversity Surveys.

*Note:* *Due to the conservation status of Postelsia palmaeformis, we removed all site-specific metadata from all publicly-available data and code. Because of this, R scripts to produce the map figure (Figure 2B) are not published in this repository*.

Analyses, results, figures, and tables presented in the manuscript were produced with R version 4.5.1 using the following packages: biscale (v1.0.0), gratia (v0.10.0), gt (v1.0.0), sf (v1.0-21), ggpubr (v0.6.1), cowplot (v1.2.0), mapdata (v2.3.1), maps (v3.4.3), ggthemes (v5.1.0), emmeans (v.1.11.2), lmerTest (v3.1-3), lme4 (v1.1-37), Matrix (v.1.7-3), heatwaveR (v0.5.4), lmqq (v1.5.8), DHARMa (v0.4.7), glmmTMB (v1.1.11), mgcv (v1.9-3), nlme (v3.1-168), lubridate (v1.9.4), forcats (v1.0.0), stringr (v.1.5.1), dplyr (v1.1.4), purrr (v1.0.4), readr (v2.1.5), tidyr (v1.3.1), tibble (v3.3.0), ggplot2 (v3.5.2), and tidyverse (v2.0.0).

------------------------------------------------------------------------

### Directory Information

#### Folder "[data](https://github.com/fgerraty/Postelsia_Collapse/tree/main/data)" houses processed data files associated with this repository.

-   See "[data dictionary](https://github.com/fgerraty/Postelsia_Collapse/blob/main/data/README.md)" for details on data files and associated metadata

#### Folder "[scripts](https://github.com/fgerraty/Postelsia_Collapse/tree/main/scripts)" houses R code associated with this repository

-   See section above for details on R scripts.

#### Folder "[output](https://github.com/fgerraty/Postelsia_Collapse/tree/main/output)" houses the following folders

-   Folder [**main_figures**](https://github.com/fgerraty/Postelsia_Collapse/tree/main/output/main_figures) containing figures in manuscript main text

-   Folder [**supplemental_figures**](https://github.com/fgerraty/Postelsia_Collapse/tree/main/output/supplemental_figures) containing figures in manuscript supplemental information

-   Folder [**extra_figures**](https://github.com/fgerraty/Postelsia_Collapse/tree/main/output/extra_figures) containing supporting figures not included in manuscript main text or supplemental information. This is where figure components are output prior to being combined and/or modified using illustrator.
