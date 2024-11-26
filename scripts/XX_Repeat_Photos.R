##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script XX: Repeat Photo Analyses #######################################
#-------------------------------------------------------------------------

pct_cover_photos <- read_csv("data/raw/pct_cover_photos_raw.csv") %>% 
  mutate(photo = paste(marine_site_name, pan, sep = "_")) 

temp <- pct_cover_photos %>% 
        group_by(photo) %>% 
        summarise(n = length(unique(year)))



ggplot(pct_cover_photos, aes(x=year, y=pct_postelsia)) +
  geom_point()+
  geom_smooth()+
  facet_wrap(facets = "photo", scales = "free_y")


