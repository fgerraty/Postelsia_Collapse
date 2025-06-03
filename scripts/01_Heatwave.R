##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 01: Marine Heatwave Detection + Visualization ###################
#-------------------------------------------------------------------------

##############################
# Import and prepare data ####
##############################

temperature <- read_csv("data/processed/temperature.csv") %>% 
  rename(t = date,
         temp = mean) %>% 
  mutate(site_id = factor(site_id))


##############################
# Detect Marine Heatwaves ####
##############################

# Create named list of temperature data for each site ####

# Define site IDs
site_ids <- c("1", "2", "3", "5", "8", "12", "13", "14", "16", "17")

# Filter temperature data by site and store in a named list
SST_site <- lapply(site_ids, function(current_site) {
  temperature %>%
    filter(site_id == current_site) %>%  # Use the current site value
    select(t, temp)
})
names(SST_site) <- site_ids  # Assign names to the list


# Generate site-level climatology data ####

# Calculate climatology for each site
clim_site <- lapply(names(SST_site), function(site) {
  # Calculate climatology
  climatology <- ts2clm(SST_site[[site]], x = t, y = temp, pctile = 90,
                        climatologyPeriod = range(SST_site[[site]]$t))
  
  climatology  # Return the climatology
})
names(clim_site) <- names(SST_site)  # Assign names to the list


# Detect MHW events for all sites ####

# Detect MHWs from each site's climatology data
events <- lapply(names(clim_site), function(site) {
  detect_event(clim_site[[site]], coldSpells = FALSE)
})
names(events) <- names(clim_site)  # Assign names to the list


# Summarize marine heatwave (MHW) days per year for each site ####

# Extract and summarize MHW days from the "climatology" sub-list
MHW_days_per_site <- lapply(names(events), function(site) {
  events[[site]]$climatology %>%
    mutate(year = year(t)) %>%  # Extract the year from the date
    group_by(year) %>%
    summarize(mhw_days = sum(event, na.rm = TRUE),  # Count MHW days per year
              na_count = sum(is.na(temp)), # Count days with no data
              .groups = "drop") %>%  
    mutate(site_id = factor(site))  # Add site name for reference
})

# Combine results into a summary dataframe
MHW_summary <- bind_rows(MHW_days_per_site) %>% 
  mutate(year = as.numeric(year))

#Identify site-year combinations with too sparse of water temperature data 
# (threshold = 25 days missing)
too_little_data <- MHW_summary %>% 
  filter(na_count > 25) %>% 
  select(site_id, year)


# Summarize marine heatwave days in each category per year for each site ####

# Categorize MHW events for all sites
MHW_categories <- lapply(names(events), function(site) {
  category(events[[site]], S = TRUE, name = site)
})
names(MHW_categories) <- names(events)  # Assign names to the list

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


#################################
# Summarize Marine Heatwaves ####
#################################

# Categorized heatwave summary plot ####

categorized_summary_plot_df <- MHW_categorized_summary %>% 
  select(-category) %>% 
  #Rename + pivot for plotting
  rename(Moderate = days_moderate, Strong = days_strong, 
         Severe = days_severe, Extreme = days_extreme) %>% 
  pivot_longer(cols = c("Moderate", "Strong", "Severe", "Extreme"),
               names_to = "category", 
               values_to = "duration") %>% 
  #Remove site-years with too sparse water temp data
  anti_join(too_little_data, by = c("site_id", "year"))%>% 
  #Summarize across heatwave events within sites, categories, years
  group_by(site_id, category, year) %>% 
  summarize(sum_heatwave_days = sum(duration), .groups="drop") %>% 
  #Summarize across sites by category + year
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
        legend.position.inside = c(0.86, 0.84)) 
categorized_summary_plot

ggsave("output/extra_figures/MHW_category_plot.png", categorized_summary_plot,
       width = 6.5, height = 6.5, units = "in", dpi = 600)


# All sites heatwave categorized plot ####

all_site_MHW_summary_plot_df <- MHW_categorized_summary %>% 
  select(-category) %>% 
  #Rename + pivot for plotting
  rename(Moderate = days_moderate, Strong = days_strong, 
         Severe = days_severe, Extreme = days_extreme) %>% 
  pivot_longer(cols = c("Moderate", "Strong", "Severe", "Extreme"),
               names_to = "category", 
               values_to = "duration") %>% 
  #Remove site-years with too sparse water temp data
  anti_join(too_little_data, by = c("site_id", "year")) %>% 
  mutate(category = factor(category, levels = c( "Extreme","Severe","Strong","Moderate")),
         site_id = factor(site_id, levels = c(site_ids)))


all_site_summary_plot <- ggplot(all_site_MHW_summary_plot_df, aes(x=year, y=duration, fill = category))+
  geom_bar(stat="identity")+
  scale_fill_manual(values = MHW_colours)+
  labs(x="Year", 
       y="Marine Heatwave Days",
       fill = "Intensity")+
  facet_wrap(facets = "site_id")+
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
        legend.position.inside = c(0.85, 0.1)
  ) 
all_site_summary_plot

ggsave("output/supplemental_figures/MHW_category_all_sites.png", all_site_summary_plot,
       width = 8, height = 8, units = "in", dpi = 600)


##################
# GAM ############
##################

gam_heatwave_data <- MHW_summary %>% 
  filter(na_count < 25)

set.seed(99)

#Fit GAM
heatwave_gam <- gam(
  mhw_days ~ s(year, k = 10) + #Year as smooth predictor
    s(site_id, bs = "re"), #Site as a random effect
  data = gam_heatwave_data,
  method = "REML") # Use restricted maximum likelihood for smoother estimation

summary(heatwave_gam)

# Interrogate GAM model
par(mfrow = c(2, 2)) # Set up plotting grid
gam.check(heatwave_gam)

plot(heatwave_gam, pages = 1, rug = TRUE, shade = TRUE)
plot(residuals(heatwave_gam) ~ gam_heatwave_data$year)


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


############################
# Heatwave Summary Plot ####
############################

heatwave_summary_plot <- ggplot(MHW_summary, aes(x=year)) +
  geom_point(aes(y=mhw_days),color = "red")+
  geom_line(data = gam_predictions, aes(y=fit), 
            color = "red", linewidth = 1)+
  geom_ribbon(data = gam_predictions, aes(ymin = lower, ymax = upper),
              fill = "red", alpha = 0.4) +
  coord_cartesian(ylim = c(0,150), xlim = c(2000,2024))+
  labs(x="", y="Marine heatwave index\n(# days / year)")+
  theme_few()+
  theme(axis.text.x = element_blank(),
        panel.border = element_rect(linewidth = 2),
        strip.text = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold")) 
heatwave_summary_plot

ggsave("output/extra_figures/summary_figure/heatwave_summary.png", heatwave_summary_plot, 
       width = 6, height = 2.5, units = "in", dpi = 600)


#################################
# Single Site Example Plot ######
#################################

# Longer-term example plot #####

# Create category breaks and select slice of data.frame
clim_cat <- events$"5"$climatology %>%
  mutate(diff = thresh - seas,
         thresh_2x = thresh + diff,
         thresh_3x = thresh_2x + diff,
         thresh_4x = thresh_3x + diff) %>% 
  filter(t > as.Date("2013-01-01") & t < "2018-01-01")

# Set line colours
lineColCat <- c(
  "Temperature" = "black",
  "Climatology" = "blue",
  "Threshold" = "darkgreen"
)

# Set category fill colours
fillColCat <- c(
  "Moderate" = "#ffc866",
  "Strong" = "#ff6900",
  "Severe" = "#9e0000",
  "Extreme" = "#2d0000"
)

# Create plot
example_plot <- ggplot(clim_cat, aes(x = t, y = temp)) +
  geom_flame(aes(y2 = thresh, fill = "Moderate")) +
  geom_flame(aes(y2 = thresh_2x, fill = "Strong")) +
  geom_flame(aes(y2 = thresh_3x, fill = "Severe")) +
  geom_flame(aes(y2 = thresh_4x, fill = "Extreme")) +
  geom_line(aes(y = temp, col = "Temperature"), size = 0.6) +
  geom_line(aes(y = seas, col = "Climatology"), size = 0.7) +
  geom_line(aes(y = thresh, col = "Threshold"), size = 0.7) +
  geom_rect(aes(xmin = as.Date("2014-05-01"), xmax = as.Date("2015-07-01"), 
                ymin = 8.5, ymax = 18), 
            fill = NA,
            color = "grey40",
            linetype = "dashed")+

  
  scale_colour_manual(name = NULL, values = lineColCat,
                      limits = c("Temperature", "Climatology", "Threshold")) +
  scale_fill_manual(name = NULL, values = fillColCat, guide = FALSE) +
  scale_x_date(date_labels = "%b %Y", 
               limits = c(as.Date("2014-01-01"), as.Date("2017-01-01"))) +
  labs(y = "Temperature (°C)", x = NULL) +
  theme_few() +
  theme(legend.position = "inside",
        legend.position.inside = c(.72, .85),
        panel.border = element_rect(linewidth = 1.2,
                                       colour = "black"),
        legend.box.background = element_rect(linewidth = 1, color = "black"),
        axis.title.y = element_text(face = "bold"))+
  guides(
    colour = guide_legend(nrow = 1, override.aes = list(
      linetype = c("solid", "solid", "solid"),
      size = c(0.6, rep(0.7, 2)))))
example_plot

ggsave("output/extra_figures/heatwave_panel_a.png", example_plot, 
       width = 7, height = 2.5, units = "in")

# Extract the legend and export for later

heatwave_legend <- get_legend(example_plot) %>% 
  as_ggplot()

heatwave_legend

ggsave("output/extra_figures/heatwave/legend.png", heatwave_legend, 
       width = 7, height = 1, units = "in")


# Shorter-term example plot #####


# Set line colours
lineColCat2 <- c(
  "Temperature" = "black",
  "Climatology" = "blue",
  "Threshold" = "darkgreen",
  "2x Threshold" = "darkgreen",
  "3x Threshold" = "darkgreen",
  "4x Threshold" = "darkgreen"
)


# Create plot
example_plot_2 <- ggplot(clim_cat, aes(x = t, y = temp)) +
  geom_flame(aes(y2 = thresh, fill = "Moderate")) +
  geom_flame(aes(y2 = thresh_2x, fill = "Strong")) +
  geom_flame(aes(y2 = thresh_3x, fill = "Severe")) +
  geom_flame(aes(y2 = thresh_4x, fill = "Extreme")) +
  geom_line(aes(y = temp, col = "Temperature"), size = 0.6) +
  geom_line(aes(y = seas, col = "Climatology"), size = 0.7) +
  geom_line(aes(y = thresh, col = "Threshold"), size = 0.7) +
  geom_line(aes(y = thresh_2x, col = "2x Threshold"), size = 0.7, linetype = "dashed") +
  geom_line(aes(y = thresh_3x, col = "3x Threshold"), size = 0.7, linetype = "dotdash") +
  geom_line(aes(y = thresh_4x, col = "4x Threshold"), size = 0.7, linetype = "dotted") +
  scale_colour_manual(name = NULL, values = lineColCat2,
                      limits = c("Temperature", "Climatology", "Threshold", "2x Threshold", "3x Threshold", "4x Threshold")) +
  scale_fill_manual(name = NULL, values = fillColCat, guide = FALSE) +
  scale_x_date(date_labels = "%b %Y", 
               limits = c(as.Date("2014-05-01"), as.Date("2015-07-01"))) +
  scale_y_continuous(limits = c(9, 19))+
  labs(y = "Temperature (°C)", x = NULL) +
  theme_few() +
  theme(legend.position = "inside",
        legend.position.inside = c(.88, .75),
        panel.border = element_rect(linewidth = 1.2,
                                    colour = "black"),
        legend.background = element_rect(linewidth = .7,
                                    colour = "black"),
        axis.title.y = element_text(face = "bold"))
example_plot_2


ggsave("output/extra_figures/heatwave_panel_b.png", example_plot_2,
       width = 7, height = 4, units = "in", dpi = 600)


#################################################
# Site-Level Heatwave Visualization  ############
#################################################

# Iterate through all sites to visualize MHW dynamics ##### 

# Define the folder for saving figures
output_folder <- "output/extra_figures/heatwave/"

# Loop through all sites and generate plots
for (site in site_ids) {
  
  # Create category breaks and select slice of data.frame
  clim_cat <- events[[site]]$climatology %>%
    mutate(diff = thresh - seas,
           thresh_2x = thresh + diff,
           thresh_3x = thresh_2x + diff,
           thresh_4x = thresh_3x + diff) %>% 
    filter(t > as.Date("2013-01-01") & t < "2018-01-01") %>% 
    #Append helper "temp" value immediately preceding marine heatwaves to fix geom_flame issue
    mutate(
      na_group = cumsum(!is.na(temp)),  # Create a grouping variable for NA runs
      temp = ifelse(is.na(temp) & lead(!is.na(temp), default = TRUE), seas, temp)  # Replace last NA in each run
    ) %>%
    select(-na_group)  # Remove helper column
  
  # Create plot
  site_plot <- ggplot(clim_cat, aes(x = t, y = temp)) +
    geom_flame(aes(y2 = thresh, fill = "Moderate")) +
    geom_flame(aes(y2 = thresh_2x, fill = "Strong")) +
    geom_flame(aes(y2 = thresh_3x, fill = "Severe")) +
    geom_flame(aes(y2 = thresh_4x, fill = "Extreme")) +
    geom_line(aes(y = temp, col = "Temperature"), size = 0.6) +
    geom_line(aes(y = seas, col = "Climatology"), size = 0.7) +
    geom_line(aes(y = thresh, col = "Threshold"), size = 0.7) +
    scale_colour_manual(name = NULL, values = lineColCat,
                        limits = c("Temperature", "Climatology", "Threshold")) +
    scale_fill_manual(name = NULL, values = fillColCat, guide = FALSE) +
    scale_x_date(date_labels = "%b %Y", 
                 limits = c(as.Date("2014-01-01"), as.Date("2017-01-01"))) +
    scale_y_continuous(breaks = scales::breaks_pretty(n = 4)) + 
    labs(y = "Temperature (°C)", x = NULL) +
    theme_few() +
    theme(legend.position = "none",
          axis.text.x = element_blank()) +
    guides(
      colour = guide_legend(nrow = 1, override.aes = list(
        linetype = c("solid", "solid", "solid"),
        size = c(0.6, 0.7, .7))))
  
  # Save the plot
  ggsave(filename = paste0(output_folder, "heatwave_site_", site, ".png"),
         plot = site_plot, width = 5, height = 2.5, dpi = 600)
}


#################################################
# Site-Level Heatwave Summary Table  ############
#################################################

MHW_summary_table_gt <- temperature %>% 
  group_by(site_id) %>% 
  #Basic temp summaries
  summarise(temperature_days = n(), #number of days with data
            temperature_years = length(unique(year)), #number of years with data
            max_temp = max(temp), #max temp
            n_days_above_18c = sum(temp>18), #number of days above 18c
            n_days_above_15c = sum(temp>15)) %>%  #number of days above 15c
  #Join with dataframe in which MHWs were detected and summarized
  left_join(MHW_categorized_summary %>% 
              group_by(site_id) %>% 
              #Calculate number of days in each MHW category
              summarise(days_moderate = sum(days_moderate),
                        days_strong = sum(days_strong),
                        days_severe = sum(days_severe),
                        days_extreme = sum(days_extreme)), 
            by = join_by(site_id)) %>% 
  #Turn into proportions
  mutate(prop_days_moderate = days_moderate/temperature_days,
         prop_days_strong = days_strong/temperature_days,
         prop_days_severe = days_severe/temperature_days,
         prop_days_extreme = days_extreme/temperature_days) %>% 
  #Make pretty for gt table
  mutate(
    moderate = paste0(days_moderate, " (", round(100 * prop_days_moderate, 2), "%)"),
    strong   = paste0(days_strong, " (", round(100 * prop_days_strong, 2), "%)"),
    severe   = paste0(days_severe, " (", round(100 * prop_days_severe, 2), "%)"),
    extreme  = paste0(days_extreme, " (", round(100 * prop_days_extreme, 2), "%)")
  ) %>% 
  select(site_id, temperature_days, temperature_years, max_temp, 
         n_days_above_15c, n_days_above_18c,
         moderate, strong, severe, extreme) %>% 
  gt()


MHW_table <- 
  MHW_summary_table_gt |>
  tab_header(
    title = "Site-Level Summary of Water Temperature Data"
  ) |>
  cols_label(site_id = md("**Site**"),
             temperature_days = md("**# days with water temperature data**"),
             temperature_years = md("**# years with water temperature data**"),
             max_temp = md("**Maximum recorded water temperature**"),
             n_days_above_15c = md("**# days with water temperature exceeding 15 C**"),
             n_days_above_18c = md("**# days with water temperature exceeding 18 C**"),
             moderate = md("**# days classified as moderate MHW (% of days)**"),
             strong = md("**# days classified as strong MHW (% of days)**"),
             severe = md("**# days classified as severe MHW (% of days)**"),
             extreme = md("**# days classified as extreme MHW(% of days)**"))|>
  cols_align(
    align = "left")

MHW_table

#Export high-quality table
gtsave(MHW_table, "output/supplemental_figures/MHW_summary_table.pdf")
