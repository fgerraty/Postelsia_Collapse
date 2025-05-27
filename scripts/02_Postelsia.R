##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 01: Summarize + Visualize Postelsia Plot Data ###################
#-------------------------------------------------------------------------

#################################################
# Part 1: Import, Clean, and Summarize Data #####
#################################################

# Import data ####
postelsia <- read_csv("data/processed/postelsia_plots.csv")


# Part 2: Clean and summarize data ####


#Generate annual summary dataset
postelsia_annual_summary <- postelsia %>% 
  #Combine plots at each given site (sum of area and of total counts)
  group_by(site_id, georegion, year, season) %>% 
  summarise(total = sum(total), plot_area_m2 = sum(plot_area_m2), .groups = "drop") %>% 
  #Calculate density of postelsia
  mutate(density = total/plot_area_m2) %>% 
  #Filter for "canonical season"
  filter(case_when(
    site_id %in% c(1:12) ~ season == "Summer",
    site_id %in% c(13:17) ~ season == "Spring")) %>% 
  #Determine pre-post MHW period 
  mutate(period = ifelse(year < 2015, "pre_MHW", "post_MHW")) %>% 
  group_by(site_id) %>%
  mutate(percent_of_max = (density / max(density, na.rm = TRUE)) * 100) %>%
  ungroup() %>% 
  mutate(site_id = as.character(site_id),
         site_id = factor(site_id, levels = 1:17))


#Generate site-level summary dataset 
postelsia_summary <- postelsia_annual_summary%>% 
  #Summarise data before (all years up to and including 2014) vs after MHW (2015-onward)
  group_by(site_id, georegion, period) %>% 
  summarise(n_years = length(unique(year)),
            mean_density = mean(density), 
            se_density = sd(density)/sqrt(n()),
            .groups = "drop") %>% 
  #Bring data together in wide format
  pivot_wider(
    names_from = period, 
    values_from = c(n_years, mean_density, se_density)) %>% 
  #Calculate density change
  mutate(density_change = mean_density_post_MHW - mean_density_pre_MHW,
         percent_change = (density_change)/mean_density_pre_MHW*100,
         n_years_post_MHW = replace_na(n_years_post_MHW, 0),
         n_years_total = n_years_pre_MHW + n_years_post_MHW,
         site_id = as.character(site_id),
         site_id = factor(site_id, levels = rev(1:17)))


#####################################################################
# Part 2: Postelsia plot summary table for manuscript (Table S1) ####
#####################################################################

postelsia_table_gt <- postelsia_summary %>% 
  mutate(pre_MHW_density = sprintf("%.2f (+/- %.2f)", mean_density_pre_MHW, se_density_pre_MHW),
         post_MHW_density = sprintf("%.2f (+/- %.2f)", mean_density_post_MHW, se_density_post_MHW),
         #Remove (+/- NA) wherever it appears
         pre_MHW_density = gsub("\\(\\+/- NA\\)", "", pre_MHW_density),
         post_MHW_density = gsub("\\(\\+/- NA\\)", "", post_MHW_density)) %>% 
  select(site_id, georegion, n_years_total, 
         n_years_pre_MHW,n_years_post_MHW,
         pre_MHW_density, post_MHW_density, 
         percent_change) %>% 
  gt()


postelsia_table <- 
  postelsia_table_gt |>
  tab_header(
    title = "Site-Level Summary of Postelsia Density Data"
  ) |>
  cols_label(site_id = md("**Site**"),
             georegion = md("**Georegion**"),
             n_years_total = md("**Total survey years**"),
             n_years_pre_MHW = md("**# survey years pre-MHW**"),
             n_years_post_MHW = md("**# survey years post-MHW**"),
             pre_MHW_density = md("**Density pre-MHW (+/- SE)**"),
             post_MHW_density = md("**Density post-MHW (+/- SE)**"),
             percent_change = md("**Percent change in density**"))
postelsia_table

#Export high-quality table
gtsave(postelsia_table, "output/supplemental_figures/postelsia_summary_table.pdf")


########################################################
# Part 3: Figure 2A, bar plot of Postelsia % change ####
########################################################

bar_plot <- ggplot(postelsia_summary, aes(x=site_id, y=percent_change, 
                                          fill = percent_change > 0))+
  geom_bar(stat = "identity")+
  geom_hline(yintercept = 0)+
  scale_y_continuous(breaks = c(-100, -50, 0, 50))+
  scale_fill_manual(
    values = c("TRUE" = "#1F509A", "FALSE" = "#E38E49"))+
  coord_flip(ylim = c(-100, 95))+
  labs(x = "Site", 
       y = "Percent change of\nPostelsia density",
       fill = "")+
  theme_few()+
  theme(legend.position = "none",
        panel.border = element_rect(linewidth = 2))
bar_plot

ggsave("output/extra_figures/map/bar_plot.png", bar_plot, width = 3, height = 6.4, units = "in", dpi = 600)

#######################################################################
# Part 4: Postelsia density change vs. sampling effort (Figure SX) ####
#######################################################################

# Plot percent change of postelsia density against total number of survey years
density_vs_all_years <- ggplot(postelsia_summary, aes(x=n_years_total, y=percent_change,
                               color = percent_change > 0))+
  geom_hline(yintercept = 0, color = "grey60", linewidth = 1.5)+
  geom_point(size = 3)+
  scale_color_manual(
    values = c("TRUE" = "#1F509A", "FALSE" = "#E38E49"))+
  scale_x_continuous(limits = c(0,25))+
  scale_y_continuous(limits = c(-100,100))+
  labs(y = "Percent change of\nP. palmaeformis density", x = "Total number of survey years")+
  theme_few()+
  theme(panel.border = element_rect(linewidth = 2),
        legend.position = "none")
  
# Plot percent change of postelsia density against number of survey years pre-MHW
density_vs_pre_years <- ggplot(postelsia_summary, aes(x=n_years_pre_MHW, y=percent_change,
                               color = percent_change > 0))+
  geom_hline(yintercept = 0, color = "grey60", linewidth = 1.5)+
  geom_point(size = 3)+
  scale_color_manual(
    values = c("TRUE" = "#1F509A", "FALSE" = "#E38E49"))+
  scale_x_continuous(limits = c(0,16))+
  scale_y_continuous(limits = c(-100,100))+
  labs(y = "Percent change of\nP. palmaeformis density", x = "Number of survey years pre-MHW")+
  theme_few()+
  theme(panel.border = element_rect(linewidth = 2),
        legend.position = "none")
  
# Plot percent change of postelsia density against number of survey years post-MHW
density_vs_post_years <- ggplot(postelsia_summary, aes(x=n_years_post_MHW, y=percent_change,
                               color = percent_change > 0))+
  geom_hline(yintercept = 0, color = "grey60", linewidth = 1.5)+
  geom_point(size = 3)+
  scale_color_manual(
    values = c("TRUE" = "#1F509A", "FALSE" = "#E38E49"))+
  scale_x_continuous(limits = c(0,11))+
  scale_y_continuous(limits = c(-100,100))+
  labs(y = "", x = "Number of survey years post-MHW")+
  theme_few()+
  theme(panel.border = element_rect(linewidth = 2),
        legend.position = "none")

#Export plots
ggsave("output/extra_figures/density_vs_all_years.png", density_vs_all_years, 
       width = 7, height = 3.5, units = "in", dpi = 600)
ggsave("output/extra_figures/density_vs_pre_years.png", density_vs_pre_years, 
       width = 3.7, height = 2.5, units = "in", dpi = 600)
ggsave("output/extra_figures/density_vs_post_years.png", density_vs_post_years, 
       width = 3.7, height = 2.5, units = "in", dpi = 600)

##################################################
# Part 5: Postelsia annual trends (all sites) ####
##################################################

all_site_data <- ggplot(postelsia_annual_summary, aes(x=year, y=density))+
  # Add semi-transparent red box spanning 2014-2016
  annotate("rect", xmin = 2014, xmax = 2016, ymin = -Inf, ymax = Inf, 
           fill = "red", alpha = 0.2) +
  geom_point(size = 2, alpha = .85, color = "olivedrab4")+
  facet_wrap(facets = "site_id", scales = "free_y", ncol = 4)+
  scale_y_continuous(limits = c(0, NA))+
  labs(y = expression(bold(P. ~ palmaeformis ~ density ~ (individuals / m^2))),
       x = "Survey year")+
  theme_few()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1.1,hjust = 1),
        panel.border = element_rect(linewidth = 1.2),
        strip.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"))
all_site_data

ggsave("output/supplemental_figures/postelsia_all_sites.png", all_site_data, 
       width = 8, height = 8, units = "in", dpi = 600)
        

##################
# Part 6: GAM ####
##################

set.seed(99)

#Fit GAM
postelsia_gam <- gam(
  percent_of_max ~ s(year, k = 15) + #Year as smooth predictor
    s(site_id, bs = "re"), #Site as a random effect
  data = postelsia_annual_summary,
  method = "REML") # Use restricted maximum likelihood for smoother estimation

summary(postelsia_gam)

# Interrogate GAM model
gam.check(postelsia_gam)
k.check(postelsia_gam, subsample=5000, n.rep=400)

plot(postelsia_gam, pages = 1, rug = TRUE, shade = TRUE)
plot(residuals(postelsia_gam) ~ postelsia_annual_summary$year)


smooth_coefs(postelsia_gam, "s(site_id)")

#Identify the site_id with the median estimate, which we will use for predictions
(smooth_estimates(postelsia_gam) %>% 
  filter(.smooth == "s(site_id)") %>% 
  filter(.estimate == median(.estimate)))$site_id



#Predict values from GAM for plotting
gam_predictions <- data.frame(
  year = seq(2000, 2024, by = 0.25),
  site_id = 15
  ) %>% 
  mutate(
    fit = predict.gam(postelsia_gam, newdata = ., se.fit = TRUE)$fit,
    se = predict.gam(postelsia_gam, newdata = ., se.fit = TRUE)$se.fit,
    lower = fit - 1.96 * se,  #95% CI
    upper = fit + 1.96 * se)


# Part X: Single Summary Plot -------------------------------------------------

postelsia_summary_plot <- ggplot(postelsia_annual_summary, aes(x=year))+
  annotate("rect", xmin = 2014, xmax = 2016, ymin = -Inf, ymax = Inf, 
           fill = "red", alpha = 0.2) +
  geom_point(aes(y=percent_of_max), 
             size = 3, alpha = .5, color = "olivedrab4")+
  geom_line(data = gam_predictions, aes(y=fit), 
            color = "olivedrab4", linewidth = 1)+
  geom_ribbon(data = gam_predictions, aes(ymin = lower, ymax = upper),
              fill = "olivedrab4", alpha = 0.4) +
  labs(y = "P. palmaeformis density (% of maximum)",
       x = "Year")+
  theme_few()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1.1,hjust = 1),
        panel.border = element_rect(linewidth = 2),
        strip.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold")) 
postelsia_summary_plot

ggsave("output/extra_figures/postelsia_summary.png", postelsia_summary_plot, 
       width = 7, height = 5, units = "in", dpi = 600)



#Miniature summary plot

postelsia_summary_plot_mini <- ggplot(postelsia_annual_summary, aes(x=year))+
  annotate("rect", xmin = 2014, xmax = 2016, ymin = -Inf, ymax = Inf, 
           fill = "red", alpha = 0.2) +
  geom_point(aes(y=percent_of_max), 
             size = 3, alpha = .5, color = "olivedrab4")+
  geom_line(data = gam_predictions, aes(y=fit), 
            color = "olivedrab4", linewidth = 1)+
  geom_ribbon(data = gam_predictions, aes(ymin = lower, ymax = upper),
              fill = "olivedrab4", alpha = 0.4) +
  labs(y = "P. palmaeformis density\n(% of maximum)",
       x = "")+
  theme_few()+
  theme(axis.text.x = element_blank(),
        panel.border = element_rect(linewidth = 2),
        strip.text = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold")) 
postelsia_summary_plot_mini

ggsave("output/extra_figures/summary_figure/postelsia_summary.png", postelsia_summary_plot_mini, 
       width = 6, height = 2.5, units = "in", dpi = 600)
