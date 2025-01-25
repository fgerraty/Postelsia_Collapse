##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 03: Sea Star Data Analyses ######################################
#-------------------------------------------------------------------------

#################################################
# Part 1: Import, Clean, and Summarize Data #####
#################################################

#Import star data
stars <- read_csv("data/processed/stars.csv")


#Clean and Summarize Data 
stars_summary <- stars %>% 
  #Add up star biomass values for all size classes in a given survey
  group_by(site_id, year, season) %>% 
  summarise(sum_pisaster_biomass_g = sum(pisaster_biomass_g), 
            .groups = "drop") %>% 
  #Take mean star biomass for each site-year combination
  group_by(site_id, year) %>%
  summarise(pisaster_biomass_g = mean(sum_pisaster_biomass_g), 
            .groups = "drop") %>% 
  #Calculate percent of maximum biomass for each site-year combination
  group_by(site_id) %>% 
  mutate(percent_of_max = (pisaster_biomass_g / max(pisaster_biomass_g, na.rm = TRUE)) * 100) %>%
  ungroup() %>% 
  #Turn site_id into a factor
  mutate(site_id = factor(site_id))



##################################################
# Part 2: Pisaster annual trends (all sites) #####
##################################################

ggplot(stars_summary, aes(x=year, y=pisaster_biomass_g))+
  annotate("rect", xmin = 2014, xmax = 2016, ymin = -Inf, ymax = Inf, 
           fill = "red", alpha = 0.2) +
  geom_point(color = "purple3")+
  facet_wrap(facets = "site_id",
             scales = "free_y"
           )+
  scale_y_continuous(limits = c(0, NA))+
  labs(y = expression(bold(P. ~ ochraceous ~ biomass ~ (kg))),
       x = "Survey year")+
  theme_few()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1.1,hjust = 1),
        panel.border = element_rect(linewidth = 1.2),
        strip.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"))

##################
# Part 3: GAM ####
##################

set.seed(99)

#Fit GAM
star_gam <- gam(
  percent_of_max ~ s(year, k = 5) + #Year as smooth predictor
    s(site_id, bs = "re"), #Site as a random effect
  data = stars_summary,
  method = "REML") # Use restricted maximum likelihood for smoother estimation

summary(star_gam)

# Interrogate GAM model
par(mfrow = c(2, 2)) # Set up plotting grid
gam.check(star_gam)

plot(star_gam, pages = 1, rug = TRUE, shade = TRUE)
plot(residuals(star_gam) ~ stars_summary$year)


smooth_coefs(star_gam, "s(site_id)")

#Identify the site_id with the median estimate, which we will use for predictions
(smooth_estimates(star_gam) %>% 
    filter(.smooth == "s(site_id)") %>% 
    filter(.estimate == median(.estimate)))$site_id



#Predict values from GAM for plotting
gam_predictions <- data.frame(
  year = seq(2000, 2021, by = 0.25),
  site_id = 12
) %>% 
  mutate(
    fit = predict.gam(star_gam, newdata = ., se.fit = TRUE)$fit,
    se = predict.gam(star_gam, newdata = ., se.fit = TRUE)$se.fit,
    lower = fit - 1.96 * se,  #95% CI
    upper = fit + 1.96 * se)




# Single summary plot 
stars_summary_plot <- ggplot(stars_summary, aes(x=year))+
  # Add a vertical red bar for MHW duration
  annotate("rect", xmin = 2014, xmax = 2016, ymin = -Inf, ymax = Inf, 
           fill = "red", alpha = 0.2) +
  # Add a vertical dashed line at 2013 for SSWD onset
  geom_vline(xintercept = 2013, linetype = "dashed", 
             color = "red", linewidth = 1) +
  geom_point(aes(y=percent_of_max), size = 3, alpha = .5, color = "purple3")+
  
  geom_line(data = gam_predictions, aes(y=fit), 
            color = "purple3", linewidth = 1)+
  geom_ribbon(data = gam_predictions, aes(ymin = lower, ymax = upper),
              fill = "purple1", alpha = 0.4) +
  labs(y = "P. ochraceous biomass (% of maximum)",
       x = "Survey year")+
  theme_few()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1.1,hjust = 1),
        panel.border = element_rect(linewidth = 2),
        strip.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold")) 
stars_summary_plot

ggsave("output/extra_figures/stars_summary.png", stars_summary_plot, 
       width = 7, height = 5, units = "in", dpi = 600)


