##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script XX: Repeat Photo Analyses #######################################
#-------------------------------------------------------------------------

panoramic_photos <- read_csv("data/processed/panoramic_photos.csv") %>% 
  mutate(period = case_when(year < 2014 ~ "pre_MHW", 
                            year >= 2014 & year <= 2016 ~ "MHW",
                            year > 2016 ~ "post_MHW"),
         period = factor(period, levels = c("pre_MHW", "MHW", "post_MHW"))) 
  




panoramic_photos_long <- panoramic_photos %>% 
  mutate(photo_id = paste(site_id, pan, sep = "_")) %>% 
  #rename columns
  rename(postelsia = percent_postelsia, mussel = percent_mussel) %>% 
  #pivot data longer
  pivot_longer(cols = c("postelsia", "mussel"),
               names_to = "species", 
               values_to = "percent_cover") %>% 
  #Calculate percent of maximum percent cover (i.e. the maximum percent cover for each site and panoramic photo across all years) for each year x 2 species
  group_by(site_id, pan, photo_id, species) %>% 
  mutate(percent_of_max = (percent_cover /  max(percent_cover, na.rm = TRUE)) * 100) %>%
  ungroup()
  
    
###############################  
#All sites summary plot #######
###############################

photo_summary <- ggplot(panoramic_photos_long, aes(x=year, y=percent_of_max, 
                                              color = species, fill = species)) +
  # Add semi-transparent red box spanning 2014-2016
  annotate("rect", xmin = 2014, xmax = 2016, ymin = -Inf, ymax = Inf, 
           fill = "red", alpha = 0.2) +
  #Add points
  geom_point(size = 3, alpha = .7)+
  geom_smooth()+
  labs(x = "Year", y= "Percent of Maximum Abundance", fill = "Species", color = "Species")+
  scale_fill_manual(values = c("darkblue", "olivedrab4"),
                    labels = c("Mussel", "Postelsia"))+
  scale_color_manual(values = c("darkblue", "olivedrab4"),
                     labels = c("Mussel", "Postelsia"))+
  theme_few()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1.1,hjust = 1),
        panel.border = element_rect(linewidth = 2),
        strip.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        legend.title=element_text(face="bold"),
        legend.position = "inside", 
        legend.position.inside = c(0.8, 0.5)) 
photo_summary

ggsave("output/extra_figures/photo_summary.png", photo_summary, 
       width = 6, height = 6, units = "in", dpi = 600)



##################################
#Postelsia vs Mussels Plot #######
##################################

mean_plot_df <- panoramic_photos %>% 
  group_by(period) %>% 
  summarise(mean_postelsia = mean(percent_postelsia),
            mean_mussel = mean(percent_mussel))


mussel_postelsia_plot <- ggplot(panoramic_photos, aes(x=percent_mussel, y=percent_postelsia, 
                                                   color = period)) +
  #Add points
  geom_point(size = 3, alpha = .5)+
  geom_point(data = mean_plot_df, 
             aes(x=mean_mussel, y=mean_postelsia), 
             size = 10)+
  scale_color_manual(values = c("#648fff", "#dc267f", "#ffb000"),
                     labels = c("Pre-MHW", "MHW", "Post-MHW"))+
  labs(x="Mussel abundance (percent cover)",
       y = "Postelsia abundance (percent cover)",
       color = "Period")+
  theme_few()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1.1,hjust = 1),
        panel.border = element_rect(linewidth = 2),
        strip.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        legend.title=element_text(face="bold"),
        legend.position = "inside", 
        legend.position.inside = c(0.8, 0.75)) 


ggsave("output/extra_figures/mussel_vs_postelsia.png", mussel_postelsia_plot, 
       width = 7, height = 5, units = "in", dpi = 600)
  