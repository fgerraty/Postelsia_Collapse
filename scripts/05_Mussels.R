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
  mutate(period = factor(period, levels = c("pre_ssw", "post_ssw")),
         site_id = factor(site_id),
         transect = factor(transect))

cbs_surveys <- mussels %>% 
  group_by(site_id, period) %>% 
  summarise(survey_years = length(unique(year)), .groups = "drop")

mussel_percent_cover <- read_csv("data/processed/mussel_percent_cover.csv") %>% 
  #Assign period = pre- or post-SSWD
  mutate(period = if_else(year < 2014, "pre_ssw", "post_ssw")) %>% 
  #Remove data from sites without surveys in pre- and post-SSWD periods
  filter(!site_id %in% c(2, 5, 11)) %>% 
  #Assign period based on SSWD status
  mutate(period = factor(period, levels = c("pre_ssw", "post_ssw")),
         site_id = factor(site_id))


#####################################################
# Part 2: Mussel Expansion Heatmap  (All Sites) #####
#####################################################

heatmap_df <- mussels %>% 
  group_by(site_id, period, transect, location) %>% 
  summarise(mussel_years = n(), .groups = "drop") %>% 
  right_join(cbs_surveys, by = join_by(site_id, period)) %>% 
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


###############################################
# Part 3: Mussel Depth Distribution Plot  #####
###############################################

mussel_tidal_height_distribution <- ggplot(mussels, aes(x=tidal_elevation, fill = period, color = period))+
  geom_density(alpha = .8)+
  geom_boxplot(data = mussels %>% filter(period == "post_ssw"), 
               aes(x = as.numeric(tidal_elevation), y = .78),   
               width = 0.04, alpha = 0.7, outlier.shape = NA) +
  geom_boxplot(data = mussels %>% filter(period == "pre_ssw"), 
               aes(x = as.numeric(tidal_elevation), y = .85),   
               width = 0.04, alpha = 0.7, outlier.shape = NA) +
  scale_x_reverse()+
  scale_color_manual(values = c("#d8be02", "#0088d9"), labels = c("Pre-SSWD", "Post-SSWD"))+
  scale_fill_manual(values = c("#d8be02", "#0088d9"), labels = c("Pre-SSWD", "Post-SSWD"))+
  labs(y="Frequency", x="Mussel tidal height\n(meters from MLLW)", 
       fill = "Period", color = "Period")+
  theme_few()+
  theme(panel.border = element_rect(linewidth = 1.2),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        legend.title = element_text(face = "bold"),
        legend.position = "none"
        )
mussel_tidal_height_distribution


ggsave("output/extra_figures/mussel_tidal_height_distribution.png", mussel_tidal_height_distribution, 
       width = 4, height = 3, units = "in", dpi = 600)


##########################################
# Mussel Depth Distribution Analysis #####
##########################################

th_mod_df <- mussels %>% 
  mutate(combined_group = factor(interaction(site_id, transect)))

th_model <- lqmm(fixed = tidal_elevation ~ period, 
     random = ~1, 
     group = combined_group,
     tau = c(0.1,0.5,0.9),
     data = th_mod_df,
     control = lqmmControl(method = "df", UP_max_iter = 200)
) 

summary(th_model)

##########################################
# Part 3: Mussel Percent Cover Plot  #####
##########################################

mussel_percent_cover_plot <- ggplot(mussel_percent_cover, aes(x=percent_cover, fill = period, color = period))+
  geom_density(alpha = .8)+
  geom_boxplot(data = mussel_percent_cover %>% filter(period == "pre_ssw"), 
               aes(x = percent_cover, y = .03),   
               width = 0.0015, alpha = 0.7, outlier.shape = NA) +
  geom_boxplot(data = mussel_percent_cover %>% filter(period == "post_ssw"), 
               aes(x = percent_cover, y = .0273),   
               width = 0.0015, alpha = 0.7, outlier.shape = NA) +
  scale_color_manual(values = c("#d8be02", "#0088d9"), labels = c("Pre-SSWD", "Post-SSWD"))+
  scale_fill_manual(values = c("#d8be02", "#0088d9"), labels = c("Pre-SSWD", "Post-SSWD"))+
  labs(y="Frequency", x="Percent Cover", 
       fill = "Period", color = "Period")+
  theme_few()+
  theme(panel.border = element_rect(linewidth = 1.2),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        legend.title = element_text(face = "bold"),
        legend.position = "none"
        )
mussel_percent_cover_plot

ggsave("output/extra_figures/mussel_percent_cover.png", 
       mussel_percent_cover_plot, 
       width = 4, height = 2.8, units = "in", dpi = 600)


##########################################
# Mussel Percent Cover Analysis  #########
##########################################

pc_model <- glmmTMB(percent_cover ~ period + 
                      (1 | site_id), 
                    data = mussel_percent_cover,
                    family=gaussian())
summary(pc_model)

#Check residuals for normality
shapiro.test(resid(pc_model))

# Check pc_model assumptions with DHARMa package
pc_res = simulateResiduals(pc_model)
plot(pc_res, rank = T)
testDispersion(pc_res)
plotResiduals(pc_res, mussel_percent_cover$site_id, xlab = "Site", main=NULL)


