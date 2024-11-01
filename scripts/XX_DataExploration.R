##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script XX: Data Exploration ############################################
#-------------------------------------------------------------------------

postelsia_raw <- read_csv("data/raw/postelsia_counts_2024Nov1.csv")

postelsia_summary <- postelsia_raw %>% 
  select(marine_site_name, marine_common_year, season_name, plot_code, total, plot_area_m2) %>% 
  filter(marine_site_name == "Point Sierra Nevada")

temp <- postelsia_summary %>% 
  select(marine_site_name, marine_common_year, season_name) %>% 
  group_by(marine_site_name, season_name) %>% 
  summarize(year_count = length(unique(marine_common_year))) %>% 
  filter


ggplot(postelsia_summary, aes(x=marine_common_year, y=total, fill = season_name))+
  geom_bar(stat = "identity", position = "dodge")

+
  facet_wrap(facets = "marine_site_name", scales = "free_y")
