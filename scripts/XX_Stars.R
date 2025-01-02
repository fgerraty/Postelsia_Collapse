stars_raw <- read_csv("data/raw/seastarkat_size_count_zeroes_totals.csv")

stars <- stars_raw %>% 
  #Filter for only postelsia sites
  filter(site_code %in% c("SHT", "SEA", "BML", "SCT","PSN")) %>% 
  #Filter for only Pisaster ochraceus
  filter(species_code=="PISOCH") %>% 
  #Filter for surveys after 2004
  filter(marine_common_year >= 2012) %>% 
  #Remove rows with blank star counts
  drop_na(size_bin) %>% 
  filter(size_bin != "NM") %>% 
  #Make columns numeric
  mutate(size_bin = as.numeric(size_bin))%>% 
  #Calculate pisaster biomass using equation from Moritsch and Raimondi (2018) 
  #(https://doi.org/10.1002/ece3.3953)
  mutate(pisaster_biomass_g = total * exp(log(size_bin)*2.34723-5.50262))


stars_summary <- stars %>% 
  group_by(marine_site_name, marine_common_year, marine_common_season) %>% 
  summarise(sum_pisaster_biomass_g = sum(pisaster_biomass_g), 
            .groups = "drop") %>% 
  mutate(survey_id = paste(marine_site_name,
                           marine_common_season, 
                           sep = "_")) 



ggplot(stars_summary, aes(x=marine_common_year, y=sum_pisaster_biomass_g))+
  annotate("rect", xmin = 2014, xmax = 2016, ymin = -Inf, ymax = Inf, 
           fill = "red", alpha = 0.2) +
  geom_point()+
  geom_smooth()+
  facet_wrap(facets = "marine_site_name",
             scales = "free_y"
           )+
  theme_few()

