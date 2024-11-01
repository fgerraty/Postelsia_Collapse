##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script XX: Data Exploration ############################################
#-------------------------------------------------------------------------

postelsia_raw <- read_csv("data/raw/postelsia_counts_2024Nov1.csv")

postelsia_summary <- postelsia_raw %>% 
  select(marine_site_name, marine_common_year, season_name, plot_code, total, plot_area_m2) %>% 
  mutate(density = total/plot_area_m2) %>% 
  #Filter for only sites with 15+ years of data
  group_by(marine_site_name) %>%
  filter(n_distinct(marine_common_year) > 15) %>%
  ungroup() %>% 
  #Filter for surveys after 2004
  filter(marine_common_year >= 2004) %>% 
  mutate(marine_site_name = factor(marine_site_name),
#         marine_common_year = factor(marine_common_year),
         season_name = factor(season_name), 
         plot_code = factor(plot_code))


temp <- postelsia_summary %>% 
  group_by(marine_site_name, marine_common_year, season_name) %>% 
  summarise(n_plots = length(unique(plot_code)))
  

  
 
unique(postelsia_summary$marine_site_name)

temp <- postelsia_summary %>% 
  group_by(marine_common_year) %>% 
  summarize(site_count = length(unique(marine_site_name))) 


ggplot(postelsia_summary, aes(x=marine_common_year, y=density, color=season_name))+
  geom_point()+
  geom_smooth()

#  geom_smooth()
#  geom_bar(stat = "identity", position = "dodge")#+
  facet_wrap(facets = "marine_site_name", scales = "free_y")



f1 <- gam(total ~ s(marine_common_year) + season_name + 
              s(marine_site_name, bs="re") +
              s(marine_site_name, plot_code, bs="re"),
    data = postelsia_summary,
    family = nb(),
    method="REML")
summary(f1)
plot(f1)

