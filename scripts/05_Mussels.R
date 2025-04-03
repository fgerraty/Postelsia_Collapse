##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 05: Mussel Data Analyses ######################################
#-------------------------------------------------------------------------

#################################################
# Part 1: Import, Clean, and Summarize Data #####
#################################################

mussels <- read_csv("data/processed/mussels.csv") %>% 
  #Assign period = pre- or post-SSWD
  mutate(period = if_else(year < 2014, "pre_ssw", "post_ssw")) %>% 
  #Remove data from sites without surveys in pre- and post-SSWD periods
  filter(!site_id %in% c(2, 5, 11)) %>% 
  #Remove non-California mussels
  filter(species_lump == "Mytilus californianus") %>% 
  #Change transect # to ranked value (1,2,3,etc.) not location
  group_by(site_id, year) %>% 
  mutate(transect = dense_rank(x_transect)) %>%
  ungroup() %>% 
  #Assign period based on SSWD status
  mutate(period = factor(period, levels = c("pre_ssw", "post_ssw")))

bio_surveys <- mussels %>% 
  group_by(site_id, period) %>% 
  summarise(survey_years = length(unique(year)), .groups = "drop")


#####################################################
# Part 2: Mussel Expansion Heatmap  (All Sites) #####
#####################################################

heatmap_df <- mussels %>% 
  group_by(site_id, period, transect, location) %>% 
  summarise(mussel_years = n(), .groups = "drop") %>% 
  right_join(bio_surveys, by = join_by(site_id, period)) %>% 
  mutate(mussel_freq = mussel_years/survey_years) %>% 
  select(-mussel_years, -survey_years) %>% 
  pivot_wider(names_from = period, values_from = mussel_freq, 
              values_fill = 0) %>%  #fill with 0 when NA
  mutate(
    pre_sswBin = cut(pre_ssw, breaks = c(0,.33,.66,1), include.lowest = TRUE),
    post_sswBin = cut(post_ssw, c(0,.33,.66,1), include.lowest = TRUE),
    site_id = factor(paste("Site", site_id), 
                     levels = c("Site 1", "Site 3","Site 4","Site 6",
                                "Site 7", "Site 8","Site 9","Site 10",
                                "Site 12", "Site 13","Site 14","Site 16",
                                "Site 17")))


  # Apply bi_class() to the dataframe
heatmap_df <- bi_class(heatmap_df, y = pre_sswBin, x = post_sswBin, style = "quantile", dim = 3)


heatmap_all_sites <- ggplot(heatmap_df, aes(x=transect, y=location)) +
  geom_tile(mapping = aes(color = bi_class, fill = bi_class), 
            linewidth = 0.1, show.legend = FALSE)+
  facet_wrap(facets = "site_id", scales = "free")+
  bi_scale_color(pal = "BlueYl", dim = 3, flip_axes = TRUE) +
  bi_scale_fill(pal = "BlueYl", dim = 3, flip_axes = TRUE) +
  scale_y_reverse()+
  expand_limits(y=0)+
  labs(x="Transect number", y="Distance from high to\nlow intertidal (m from baseline)")+
  theme_few()+
  theme(axis.title = element_text(face = "bold"),
        strip.text = element_text(face = "bold", color = "grey40"))

ggsave("output/extra_figures/mussel_heatmap_all_sites.png", heatmap_all_sites, 
       width = 8, height = 8, units = "in", dpi = 600)



#Build legend

breaks <- bi_class_breaks(heatmap_df, y = pre_sswBin, x = post_sswBin, style = "quantile", dim = 3, 
                          dig_lab = 3, split = TRUE)

legend <- bi_legend(pal = "BlueYl",
                    dim = 3,
                    breaks = breaks,
                    flip_axes = TRUE,
                    ylab = "Mussel Frequency Pre-SSWD",
                    xlab = "Mussel Frequency Post-SSWD",
                    size = 12)

ggsave("output/extra_figures/mussel_heatmap_all_sites_legend.png", legend, 
       width = 3.5, height = 3, units = "in", dpi = 600)


############################################################
# Part 3: Mussel Expansion Heatmap  (Example Site: 12) #####
############################################################

heatmap_df2 <- heatmap_df %>% 
  filter(site_id == "Site 12")

heatmap_example <- ggplot(heatmap_df2, aes(x=transect, y=location)) +
  geom_tile(mapping = aes(color = bi_class, fill = bi_class), 
            linewidth = 0.1, show.legend = FALSE)+
  bi_scale_color(pal = "BlueYl", dim = 3, flip_axes = TRUE) +
  bi_scale_fill(pal = "BlueYl", dim = 3, flip_axes = TRUE) +
  scale_y_reverse()+
  expand_limits(y=0)+
  labs(x="Transect number", y="Distance from high to\nlow intertidal (m from baseline)")+
  theme_few()+
  theme(panel.border = element_rect(linewidth = 1.2),
        axis.title = element_text(face = "bold"))


ggsave("output/extra_figures/mussel_heatmap_example_site.png", heatmap_example, 
       width = 8, height = 5, units = "in", dpi = 600)


##########################################
# Part 3: Mussel Depth Distribution  #####
##########################################

mussel_depth_distribution <- ggplot(mussels, aes(x=tidal_elevation, fill = period, color = period))+
  geom_density(alpha = .8)+
  geom_boxplot(data = mussels %>% filter(period == "pre_ssw"), 
               aes(x = as.numeric(tidal_elevation), y = .78),   
               width = 0.04, alpha = 0.7, outlier.shape = NA) +
  geom_boxplot(data = mussels %>% filter(period == "post_ssw"), 
               aes(x = as.numeric(tidal_elevation), y = .85),   
               width = 0.04, alpha = 0.7, outlier.shape = NA) +
  scale_x_reverse()+
  scale_color_manual(values = c("#d8be02", "#0088d9"), labels = c("Pre-SSWD", "Post-SSWD"))+
  scale_fill_manual(values = c("#d8be02", "#0088d9"), labels = c("Pre-SSWD", "Post-SSWD"))+
  labs(y="Frequency", x="Mussel depth\n(meters from MLLW)", 
       fill = "Period", color = "Period")+
  theme_few()+
  theme(panel.border = element_rect(linewidth = 1.2),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        legend.title = element_text(face = "bold"),
        legend.position = "none")
mussel_depth_distribution


ggsave("output/extra_figures/mussel_depth_distribution.png", mussel_depth_distribution, 
       width = 3.5, height = 2.75, units = "in", dpi = 600)


###################################################
# Part 3: Mussel Depth Distribution Analysis  #####
###################################################

model_df <- mussels %>% 
  mutate(tidal_elevation_shifted = tidal_elevation+2.301)



model <- glmmTMB(tidal_elevation_shifted ~ period + 
                (1 | site_id/x_transect), 
               data = model_df,
               family = tweedie())
summary(model)

model_sim <- simulateResiduals(fittedModel = model, plot = F)
plot(model_sim)
testDispersion(model_sim)

plot(model)



