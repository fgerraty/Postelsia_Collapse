##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script XX: Repeat Photo Analyses #######################################
#-------------------------------------------------------------------------

#################################################
# Part 1: Import, Clean, and Summarize Data #####
#################################################

panoramic_photos <- read_csv("data/processed/panoramic_photos.csv") %>% 
  #Assign variable for pre-, during-, or post-MHW
  mutate(period = case_when(year < 2014 ~ "pre_MHW", 
                            year >= 2014 & year <= 2016 ~ "MHW",
                            year > 2016 ~ "post_MHW"),
         period = factor(period, levels = c("pre_MHW", "MHW", "post_MHW")),
         photo_id = factor(paste(site_id, pan, sep = "_"))) %>% #Unique ID for photo location
  #Calculate percent of maximum percent cover (i.e. the maximum percent cover for each site and panoramic photo across all years) for each year x 2 species
  group_by(site_id, pan) %>% 
  mutate(postelsia_percent_of_max = (percent_postelsia / max(percent_postelsia))*100,
         mussel_percent_of_max = (percent_mussel / max(percent_mussel))*100)


panoramic_photos_long <- panoramic_photos %>% 
  select(-percent_postelsia, -percent_mussel) %>% 
  #rename columns
  rename(postelsia = postelsia_percent_of_max, mussel = mussel_percent_of_max) %>% 
  #pivot data longer
  pivot_longer(cols = c("postelsia", "mussel"),
               names_to = "species", 
               values_to = "percent_of_max") 

#############################
# Part 2: Postelsia GAM #####
#############################

set.seed(99)

#Fit GAM
postelsia_gam <- gam(
  postelsia_percent_of_max ~ s(year, k = 5) + #Year as smooth predictor
    s(photo_id, bs = "re"), #Photo as a random effect
  data = panoramic_photos,
  method = "REML") # Use restricted maximum likelihood for smoother estimation

summary(postelsia_gam)

# Interrogate GAM model
par(mfrow = c(2, 2)) # Set up plotting grid
gam.check(postelsia_gam)

plot(postelsia_gam, pages = 1, rug = TRUE, shade = TRUE)
plot(residuals(postelsia_gam) ~ panoramic_photos$year)


smooth_coefs(postelsia_gam, "s(photo_id)")

#Identify the site_id with the median estimate, which we will use for predictions
(smooth_estimates(postelsia_gam) %>% 
    filter(.smooth == "s(photo_id)") %>% 
    filter(.estimate == median(.estimate)))$photo_id



#Predict values from GAM for plotting
postelsia_gam_predictions <- data.frame(
  year = seq(2012, 2021, by = 0.25),
  photo_id = "13_a") %>% 
  mutate(
    fit = predict.gam(postelsia_gam, newdata = ., se.fit = TRUE)$fit,
    se = predict.gam(postelsia_gam, newdata = ., se.fit = TRUE)$se.fit,
    lower = fit - 1.96 * se,  #95% CI
    upper = fit + 1.96 * se)


#############################
# Part 2: Mussel GAM #####
#############################

set.seed(99)

#Fit GAM
mussel_gam <- gam(
  mussel_percent_of_max ~ s(year, k = 5) + #Year as smooth predictor
    s(photo_id, bs = "re"), #Photo as a random effect
  data = panoramic_photos,
  method = "REML") # Use restricted maximum likelihood for smoother estimation

summary(mussel_gam)

# Interrogate GAM model
par(mfrow = c(2, 2)) # Set up plotting grid
gam.check(mussel_gam)

plot(mussel_gam, pages = 1, rug = TRUE, shade = TRUE)
plot(residuals(mussel_gam) ~ panoramic_photos$year)


smooth_coefs(mussel_gam, "s(photo_id)")

#Identify the site_id with the median estimate, which we will use for predictions
(smooth_estimates(mussel_gam) %>% 
    filter(.smooth == "s(photo_id)") %>% 
    filter(.estimate == median(.estimate)))$photo_id



#Predict values from GAM for plotting
mussel_gam_predictions <- data.frame(
  year = seq(2012, 2021, by = 0.25),
  photo_id = "13_a") %>% 
  mutate(
    fit = predict.gam(mussel_gam, newdata = ., se.fit = TRUE)$fit,
    se = predict.gam(mussel_gam, newdata = ., se.fit = TRUE)$se.fit,
    lower = fit - 1.96 * se,  #95% CI
    upper = fit + 1.96 * se)

    
###############################  
#All sites summary plot #######
###############################

photo_summary <- ggplot(panoramic_photos_long, 
                        aes(x=year)) +
  # Add semi-transparent red box spanning 2014-2016
  annotate("rect", xmin = 2014, xmax = 2016, ymin = -Inf, ymax = Inf, 
           fill = "red", alpha = 0.2) +
  #Add points
  geom_point(aes(y=percent_of_max, color = species, fill = species), size = 3, alpha = .7)+
  #Postelsia GAM layers
  geom_line(data = postelsia_gam_predictions, aes(y=fit), 
            color = "olivedrab4", linewidth = 1)+
  geom_ribbon(data = postelsia_gam_predictions, aes(ymin = lower, ymax = upper),
              fill = "olivedrab4", alpha = 0.4) +
  #Mussel GAM layers
  geom_line(data = mussel_gam_predictions, aes(y=fit), 
            color = "darkblue", linewidth = 1)+
  geom_ribbon(data = mussel_gam_predictions, aes(ymin = lower, ymax = upper),
              fill = "darkblue", alpha = 0.4) +
  labs(x = "Year", y= "Percent of Maximum Abundance", fill = "Species", color = "Species")+
  scale_fill_manual(values = c("darkblue", "olivedrab4"),
                    labels = c("Mussel", "Postelsia"))+
  scale_color_manual(values = c("darkblue", "olivedrab4"),
                     labels = c("Mussel", "Postelsia"))+
  scale_y_continuous(breaks = c(0, 25, 50, 75, 100))+
  theme_few()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1.1,hjust = 1),
        panel.border = element_rect(linewidth = 2),
        strip.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        legend.title=element_text(face="bold"),
        legend.position = "inside", 
        legend.position.inside = c(0.8, 0.5)) 

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
  