# Data Dictionary

------------------------------------------------------------------------

### "Postelsia Plots" Dataset

The "postelsia plots" dataset ([data/processed/postelsia_plots.csv](https://github.com/fgerraty/Postelsia_Collapse/blob/main/data/processed/postelsia_plots.csv)) contains *Postelsia palmiformis* count data by plot from long-term surveys collected by the [Multi-Agency Rocky Intertidal Network](https://marine.ucsc.edu) (MARINe). The dataset contains the following columns:

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

### "Temperature" Dataset

The "temperature" dataset ([data/processed/temperature.csv](https://github.com/fgerraty/Postelsia_Collapse/blob/main/data/processed/temperature.csv)) contains intertidal water temperatuee data from 10 long-term monitoring sites collected using HOBO Pendant and TidbiT (v1 and v2) temperature loggers (Onset Computer Corporation, Bourne, Massachusetts, United States). The dataset contains the following columns:

-   **site_id** - unique number code for each site

-   **georegion** - geographical region in which a site is located

-   **date** - date of water temperature data

-   **year** - year in which water temperature data was collected (Range: 2000-2024)

-   **month** - month in which water temperature data was collected (Range: 1-12)

-   **day** - day of the month in which water temperature data was collected (Range: 1-31)

-   **day_of_year** - day of the year in which water temperature data was collected (Range: 1-366)

-   **n** - number of unique water temperature measurements (within survey day)

-   **mean** - mean water temperature (ºC) on survey day

-   **stderr** - standard error (ºC) of water temperature measurements on survey day.

### "Mussels" Dataset

The "mussels" dataset ([data/processed/mussels.csv](https://github.com/fgerraty/Postelsia_Collapse/blob/main/data/processed/mussels.csv)) contains mussel occurrence data by plot from MARINe [Coastal Biodiversity Servey (CBS) grids](#0). Each row in this dataset constitutes a single mussel detection at any layer. The dataset contains the following columns:

-   **site_id** - unique number code for each site

-   **year** - year in which CBS survey was conducted (Range: 2001-2024)

-   **month** - month in which CBS survey was conducted (Range: 1-12)

-   **day** - day of month in which CBS survey was conducted (Range: 1-31)

-   **x_transect** - A number representing one of 11 parallel meter tapes (transects) within the CBS survey area. Transects stem from a baseline, which is established along shore in the high zone of a site area. The transect number is determined by the meter mark on the baseline from where the transect begins. (Range: 0-30).

-   **location** - The location (in meters) along the transect at which the mussel was observed.

-   **species_lump** - Lumped species name. Note that only *M. californianus* mussels were included in analyses, despite that other *Mytilus* species are included in this dataset.

-   **pc_point_type** - Designates whether full_points (with layering, host/epi relationships, and nearest species information) or first_points (only the top point and/or mussels on point if a layer was over a mussel) was done during this survey. Note that mussel occurrence is documented for both point sampling types.

-   **tidal_elevation** - The calculated height in meters above Mean Low Low Water of the referenced location. These calculations are made by kriging the data in Surfer 8. See more information here: <https://support.goldensoftware.com/hc/en-us/articles/231348728-A-Basic-Understanding-of-Surfer-Gridding-Methods-Part-1#kriging>

### "Mussel Percent Cover" Dataset

The "mussel percent cover" dataset ([data/processed/mussels_percent_cover.csv](https://github.com/fgerraty/Postelsia_Collapse/blob/main/data/processed/mussel_percent_cover.csv)) contains mussel percent cover data by survey across the entire [MARINe Coastal Biodiversity Survey (CBS)](https://marine.ucsc.edu/methods/biodiversity-methods.html) grid. Each row in this dataset constitutes a single CBS survey. The dataset contains the following columns:

-   **site_id** - unique number code for each site

-   **year** - year in which CBS survey was conducted (Range: 2001-2024)

-   **number_of_transect_locations** - number of points in CBS survey grid.

-   **count** - number of points in CBS survey grid at which mussels were detected.

-   **percent_cover** - percent cover of mussels across the CBS survey grid (count / number_of_transect_locations \* 100)

### "Tidal Elevation Overlap" Dataset

The "tidal elevation overlap" dataset ([data/processed/tidal_elevation_overlap.csv](https://github.com/fgerraty/Postelsia_Collapse/blob/revisions/data/processed/tidal_elevation_overlap.csv)) contains mussel, Postelsia, and Pisaster occurrence data from [MARINe Coastal Biodiversity Survey (CBS)](https://marine.ucsc.edu/methods/biodiversity-methods.html) grids. For *Mytilus californianus* and *Postelsia palmaeformis*, each row in this dataset constitutes a single detection at any layer along CBS grid transects. For *Pisaster ochraceus*, each row represents one mobile invertebrate quadrat and the value for "count" indicates the number of *Pisaster* within each quadrat. The dataset contains the following columns:

-   **site_id** - unique letter code for each site

-   **year** - year in which CBS survey was conducted (Range: 2001-2023)

-   **species_lump** - Species name.

-   **tidal_elevation** - The calculated height in meters above Mean Low Low Water of the referenced location. These calculations are made by kriging the data in Surfer 8. See more information here: <https://support.goldensoftware.com/hc/en-us/articles/231348728-A-Basic-Understanding-of-Surfer-Gridding-Methods-Part-1#kriging>

<!-- -->

-   **count** - number of individuals detected at this location. This will always be 1 for *Mytilus* and *Postelsia*, but may be more for *Pisaster*.
