# Data Dictionary

------------------------------------------------------------------------

### "Postelsia Plots" Dataset

The "postelsia plots" dataset ([data/processed/postelsia_plots.csv](https://github.com/fgerraty/Postelsia_Collapse/blob/main/data/processed/postelsia_plots.csv)) contains *Postelsia palmiformis* count data by plot from long-term surveys collected by the [Multi-Agency Rocky Intertidal Network](https://marine.ucsc.edu). The dataset contains the following columns:

-   **site_id** -unique number code for each site

-   **georegion** - geographical region in which a site is located

-   **year** - year in which survey was conducted

-   **season** - season in which survey was conducted. *Note*: seasons are categorized to be consistent with data from in other MARINe surveys.

-   **survey_date** - date of survey.

-   **plot_code** - replicate plot number, starting from 1 at each site.

-   **total** - total number of *Postelsia palmiformis* individuals counted in the referenced plot.

-   **plot_area_m2** - the area in meters squared of the referenced plot.

### "Panoramic Photos" Dataset

The "panoramic photos" dataset ([data/processed/panoramic_photos.csv](https://github.com/fgerraty/Postelsia_Collapse/blob/main/data/processed/panoramic_photos.csv)) contains *Postelsia palmiformis* and mussel (*Mytilus californianus*) percent cover estimates derived from repeated panoramic photos taken at 5 long-term monitoring sites. See manuscript for details on how photos were processed to extract these values. The dataset contains the following columns:

-   **site_id** -unique number code for each site

-   **pan** - unique panoramic photo letter, starting from "a" at each site

-   **year** - year in which survey was conducted

-   **percent_postelsia** - percent cover of *Postelsia palmiformis.*

-   **percent_mussel** - percent cover of mussels (*Mytilus californianus*).

### "Stars" Dataset

The "stars" dataset ([data/processed/stars.csv](https://github.com/fgerraty/Postelsia_Collapse/blob/main/data/processed/stars.csv)) contains ochre star (*Pisaster ochraceus*) abundance data at the 5 long-term monitoring sites where panoramic photos were taken. The dataset contains the following columns:

-   **site_id** -unique number code for each site

-   **georegion** - geographical region in which a site is located

-   **year** - year in which survey was conducted

-   **season** - season in which survey was conducted. *Note*: seasons are categorized to be consistent with data from in other MARINe surveys.

-   **size_bin** - length (mm) of longest arm of the sea star from the center of the aboral side of the body to the arm tip, binned to the nearest 10mm

-   **total** - total number of *Pisaster ochraceus* individuals (of referenced size class) counted in the plot.

-   **pisaster_biomass_g** - estimated biomass of *Pisaster ochraceus* (of referenced size class) counted in the plot. This biomass measure was estimated using a log-log relationship between arm length and wet weight (Equation 1 from: Moritsch, M.M., Raimondi, P., 2018. Reduction and recovery of keystone predation pressure after disease-related mass mortality. Ecology and Evolution 8, 3952--3964. [**https://doi.org/10.1002/ece3.3953**](https://doi.org/10.1002/ece3.3953)).
