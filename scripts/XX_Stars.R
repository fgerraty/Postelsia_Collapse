##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script X: Stars Data ###################################################
#-------------------------------------------------------------------------

# Part 1: Import Data ----------------------------------------------------
stars <- read_csv("data/processed/stars.csv")


# Part 2: Clean and Summarize Data ---------------------------------------------
stars_summary <- stars %>% 
  group_by(site_id, year, season) %>% 
  summarise(sum_pisaster_biomass_g = sum(pisaster_biomass_g), 
            .groups = "drop") %>% 
  group_by(site_id) %>%
  mutate(percent_of_max = (sum_pisaster_biomass_g / max(sum_pisaster_biomass_g, na.rm = TRUE)) * 100) %>%
  ungroup()


# Part X: Annual Trends (All Sites) -------------------------------------------

ggplot(stars_summary, aes(x=year, y=sum_pisaster_biomass_g))+
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


# Part X: Single summary plot -------------------------------------------
stars_summary_plot <- ggplot(stars_summary, aes(x=year, y=percent_of_max))+
  # Add a vertical red bar for MHW duration
  annotate("rect", xmin = 2014, xmax = 2016, ymin = -Inf, ymax = Inf, 
           fill = "red", alpha = 0.2) +
  # Add a vertical dashed line at 2013 for SSWD onset
  geom_vline(xintercept = 2013, linetype = "dashed", 
             color = "red", linewidth = 1) +
  
  geom_point(size = 3, alpha = .5, color = "purple3")+
  geom_smooth(color = "purple3", fill = "purple1")+
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

# Part X: 2012-2021 Summary Plot ----------------------------------------------
ggplot(stars_summary, aes(x=year, y=percent_of_max))+
  annotate("rect", xmin = 2014, xmax = 2016, ymin = -Inf, ymax = Inf, 
           fill = "red", alpha = 0.2) +
  geom_point(size = 3, alpha = .5, color = "purple3")+
  geom_smooth(color = "purple3", fill = "purple1")+
  coord_cartesian(xlim = c(2012, 2021))+
  labs(y = "P. ochraceous biomass (% of maximum)",
       x = "Survey year")+
  theme_few()+
  theme(axis.text.x = element_text(angle = 45, vjust = 1.1,hjust = 1),
        panel.border = element_rect(linewidth = 2),
        strip.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold")) 
