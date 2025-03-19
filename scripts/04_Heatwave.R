##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 04: Marine Heatwave Detection + Visualization ###################
#-------------------------------------------------------------------------

######################################
# Part 1: Import and prepare data ####
######################################
temperature <- read_csv("data/processed/temperature.csv") %>% 
  rename(t = date,
         temp = mean) %>% 
  mutate(site_id = factor(site_id))


######################################
# Part 2: Detect Marine Heatwaves ####
######################################

# Part 2A: Create named list of temperature data for each site ####

# Define site IDs
site_ids <- c("1", "2", "3", "5", "8", "12", "13", "14", "16", "17")

# Filter temperature data by site and store in a named list
SST_site <- lapply(site_ids, function(current_site) {
  temperature %>%
    filter(site_id == current_site) %>%  # Use the current site value
    select(t, temp)
})
names(SST_site) <- site_ids  # Assign names to the list


# Part 2B: Generate site-level climatology data ####

# Calculate climatology for each site and save as CSV
clim_site <- lapply(names(SST_site), function(site) {
  # Calculate climatology
  climatology <- ts2clm(SST_site[[site]], x = t, y = temp, pctile = 90,
                        climatologyPeriod = range(SST_site[[site]]$t))
  
  # Save the climatology to a CSV file
  write.csv(climatology, paste0("data/processed/climatology/", site, "_climatology.csv"))
  
  climatology  # Return the climatology
})
names(clim_site) <- names(SST_site)  # Assign names to the list


# Part 2C: Detect and categorize MHW events for all sites ####

# Detect MHWs from each site's climatology data
events <- lapply(names(clim_site), function(site) {
  detect_event(clim_site[[site]], coldSpells = FALSE)
})
names(events) <- names(clim_site)  # Assign names to the list


# Categorize MHW events for all sites
MHW_categories <- lapply(names(events), function(site) {
  category(events[[site]], S = TRUE, name = site)
})
names(MHW_categories) <- names(events)  # Assign names to the list


# Part 2D. Summarize marine heatwave (MHW) days per year for each site ####

# Extract and summarize MHW days from the "climatology" sub-list
MHW_days_per_site <- lapply(names(events), function(site) {
  events[[site]]$climatology %>%
    filter(event) %>%  # Keep only rows where event == TRUE
    mutate(year = year(t)) %>%  # Extract the year from the date
    group_by(year) %>%
    summarize(mhw_days = n(), .groups = "drop") %>%  # Count MHW days per year
    mutate(site_id = factor(site))  # Add site name for reference
})

# Combine results into a summary dataframe
MHW_summary <- bind_rows(MHW_days_per_site) %>% 
  mutate(year = as.numeric(year))

#Part 2E: Summarize marine heatwave days in each category per year for each site ####

# Extract and summarize MHW days per site-category-year
MHW_days_categorized <- lapply(names(MHW_categories), function(site) {
  MHW_categories[[site]] %>% 
    mutate(site_id = site,  # Add site name as a column
           year = year(peak_date), # Extract the year from the event start date
           #Categorize number of days in each severity category
           days_moderate = duration * p_moderate/100, 
           days_strong = duration * p_strong/100,
           days_severe = duration * p_severe/100, 
           days_extreme = duration * p_extreme/100) %>%  
    group_by(site_id, category, year) %>%  # Group by site, category, and year
    #Calculate sum of days in each severity category
    summarize(days_moderate = sum(days_moderate),
              days_strong = sum(days_strong),
              days_severe = sum(days_severe),
              days_extreme = sum(days_extreme),
              .groups = "drop")  # Sum MHW days per year-category
})

names(MHW_days_categorized) <- names(events)  # Assign names to the list

# Combine into a single dataframe
MHW_categorized_summary <- bind_rows(MHW_days_categorized)


#########################################
# Part 3: Visualize Marine Heatwaves ####
#########################################

#Categorized heatwave summary plot

categorized_summary_plot_df <- MHW_categorized_summary %>% 
  select(-category) %>% 
  rename(Moderate = days_moderate, Strong = days_strong, 
         Severe = days_severe, Extreme = days_extreme) %>% 
  pivot_longer(cols = c("Moderate", "Strong", "Severe", "Extreme"),
               names_to = "category", 
               values_to = "duration") %>% 
  group_by(site_id, category, year) %>% 
  summarize(sum_heatwave_days = sum(duration), .groups="drop") %>% 
  group_by(category, year) %>% 
  summarize(mean_heatwave_days = mean(sum_heatwave_days), .groups = "drop") %>% 
  mutate(category = factor(category, levels = c( "Extreme","Severe","Strong","Moderate")))

# The MHW colour palette
MHW_colours <- c(
  "Moderate" = "#ffc866",
  "Strong" = "#ff6900",
  "Severe" = "#9e0000",
  "Extreme" = "#2d0000"
)



categorized_summary_plot <- ggplot(categorized_summary_plot_df, aes(x=year, y=mean_heatwave_days, fill = category))+
  geom_bar(stat="identity")+
  scale_fill_manual(values = MHW_colours)+
  labs(x="Year", 
       y="Marine Heatwave Days\n(mean days across all sites)",
       fill = "Intensity")+
  theme_few()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1.1,hjust = 1),
        panel.border = element_rect(linewidth = 2),
        strip.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        legend.title = element_text(face = "bold"),
        legend.box.background = element_rect(linewidth = 1.2,
                                             colour = "black"),
        legend.position = "inside",
        legend.position.inside = c(0.9, 0.8)) 
categorized_summary_plot

ggsave("output/extra_figures/MHW_category_plot.png", categorized_summary_plot,
       width = 7, height = 5, units = "in", dpi = 600)


# Single site example plot ######
# (We will use site 5 as an example)

site_5_temp <- temperature %>% 
  filter(site_id=="5")
ts5 <- ts2clm(site_5_temp, x = t, y = temp, pctile = 90,
              climatologyPeriod = range(site_5_temp$t))
MHW5 <- detect_event(ts5) 
MHW_cat5 <- category(MHW5, S = TRUE)



single_site_example <- event_line(MHW5, category = TRUE, spread = 180,
           start_date = "2011-01-01", end_date = "2016-12-31")+
  theme_few()+
  labs(y = expression("Temperature " ( degree~C)),
       x="Date")+
  theme(panel.border = element_rect(linewidth = 2),
        strip.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        legend.title = element_text(face = "bold"),
        legend.box.background = element_rect(linewidth = 1.2,
                                             colour = "black"),
        legend.position = "inside",
        legend.position.inside = c(0.88, 0.8)) 
single_site_example

ggsave("output/extra_figures/MHW_example.png", single_site_example,
       width = 7, height = 5, units = "in", dpi = 600)



##################
# Part 4: GAM ####
##################


set.seed(99)

#Fit GAM
heatwave_gam <- gam(
  mhw_days ~ s(year, k = 10) + #Year as smooth predictor
    s(site_id, bs = "re"), #Site as a random effect
  data = MHW_summary,
  method = "REML") # Use restricted maximum likelihood for smoother estimation

summary(heatwave_gam)

# Interrogate GAM model
par(mfrow = c(2, 2)) # Set up plotting grid
gam.check(heatwave_gam)

plot(heatwave_gam, pages = 1, rug = TRUE, shade = TRUE)
plot(residuals(heatwave_gam) ~ MHW_summary$year)


smooth_coefs(heatwave_gam, "s(site_id)")

#Identify the site_id with the median estimate, which we will use for predictions
(smooth_estimates(heatwave_gam) %>% 
    filter(.smooth == "s(site_id)") %>% 
    filter(.estimate == median(.estimate)))$site_id
 #NOTE: Not working because there is no median! 


#Predict values from GAM for plotting
gam_predictions <- data.frame(
  year = seq(2000, 2024, by = 0.25),
  site_id = "5") %>% 
  mutate(
    fit = predict.gam(heatwave_gam, newdata = ., se.fit = TRUE)$fit,
    se = predict.gam(heatwave_gam, newdata = ., se.fit = TRUE)$se.fit,
    lower = fit - 1.96 * se,  #95% CI
    upper = fit + 1.96 * se)


####################################
# Part 4: Heatwave Summary Plot ####
####################################

heatwave_summary_plot <- ggplot(MHW_summary, aes(x=year)) +
  geom_point(aes(y=mhw_days),color = "red")+
  geom_line(data = gam_predictions, aes(y=fit), 
            color = "red", linewidth = 1)+
  geom_ribbon(data = gam_predictions, aes(ymin = lower, ymax = upper),
              fill = "red", alpha = 0.4) +
  coord_cartesian(ylim = c(0,150), xlim = c(2000,2024))+
  labs(x="Year", y="Marine Heatwave Index\n(# Days / Year)")+
  theme_few()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1.1,hjust = 1),
        panel.border = element_rect(linewidth = 2),
        strip.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold")) 
heatwave_summary_plot

ggsave("output/extra_figures/summary_figure/heatwave_summary.png", heatwave_summary_plot, 
       width = 6, height = 2.5, units = "in", dpi = 600)
