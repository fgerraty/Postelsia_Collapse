stars_raw <- read_csv("data/raw/seastarkat_size_count_zeroes_totals.csv")

stars <- stars_raw %>% 
  filter(site_code %in% c("FOG", "SHT", "SEA", "BML", "SCT","PSN")) %>% 
  filter(species_code=="PISOCH") 


ggplot(stars, aes(x=size_bin, y=total))+
  geom_bar(stat = "identity")+
  facet_wrap(facets = "marine_common_year",
             scales = "free_y")

