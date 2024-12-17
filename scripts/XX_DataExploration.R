##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script XX: Postelsia Data Exploration ##################################
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
  
  
#Make dataframe for postelsia plot

postelsia_summary_plot_df <- postelsia_summary %>% 
  filter(season_name %in% (c("Spring", "Summer")))
  

temp <- postelsia_summary %>% 
  group_by(marine_site_name, season_name) %>% 
  summarise(n_year = length(unique(marine_common_year)))

#Check out seasonal differences in sampling at Point Sierra Nevada 
psn <- postelsia_summary %>% 
  filter(marine_site_name == "Point Sierra Nevada", 
         season_name == "Fall") #Can change this to "Fall"

ggplot(psn,
       aes(x=marine_common_year, y=density, color=season_name))+
  geom_point()+
  geom_vline(xintercept = 2015)+
  stat_smooth(#method = 'loess', 
              color = "darkgreen")+
  facet_wrap(facets = "marine_site_name", scales = "free_y")+
  theme_few()


#Check out seasonal differences in sampling at Scott Creek

scott <- postelsia_summary %>% 
  filter(marine_site_name == "Scott Creek") #Can change this to "Fall"


ggplot(scott,
       aes(x=marine_common_year, y=density, color=season_name))+
  geom_point()+
  geom_vline(xintercept = 2015)+
#  stat_smooth(#method = 'loess', 
    #color = "darkgreen"
#    )+
#  facet_wrap(facets = "marine_site_name", scales = "free_y")+
  theme_few()









ggplot(postelsia_summary,
       aes(x=marine_common_year, y=density, color = season_name))+
  # Add semi-transparent red box spanning 2014-2016
  annotate("rect", xmin = 2014, xmax = 2016, ymin = -Inf, ymax = Inf, 
           fill = "red", alpha = 0.2) +
  geom_point()+
#  geom_vline(xintercept = 2015)+
#  stat_smooth(method = 'loess', color = "darkgreen")+
  geom_smooth()+
  
  facet_wrap(facets = "marine_site_name", scales = "free_y")+
  theme_few()
  



f1 <- gam(total ~ s(marine_common_year) + season_name + 
              s(marine_site_name, bs="re") +
              s(marine_site_name, plot_code, bs="re"),
    data = postelsia_summary,
    family = nb(),
    method="REML")
summary(f1)
plot(f1)

