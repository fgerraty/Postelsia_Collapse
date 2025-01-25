##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script X: Sea Water Temperature Data ###################################
#-------------------------------------------------------------------------

# Part 1: Import and prepare data ####
temperature <- read_csv("data/processed/temperature.csv") %>% 
  rename(t = date,
         temp = mean) %>% 
  mutate(site_id = factor(site_id))

# Part 2. Create named list of temperature data for each site ####
# Define site IDs
site_ids <- c("2", "3", "5", "8", "12", "13", "14", "16", "17")

# Filter temperature data by site and store in a named list
SST_site <- lapply(site_ids, function(current_site) {
  temperature %>%
    filter(site_id == current_site) %>%  # Use the current site value
    select(t, temp)
})
names(SST_site) <- site_ids  # Assign names to the list


# Part 3. Generate site-level climatology data ####

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

# Part 4. Detect MHW events for all sites ####

# Detect MHWs from each site's climatology data
events <- lapply(names(clim_site), function(site) {
  detect_event(clim_site[[site]], coldSpells = FALSE)
})
names(events) <- names(clim_site)  # Assign names to the list

# 5. Summarize marine heatwave (MHW) days per year for each site ####

# Extract and summarize MHW days from the "climatology" sub-list
mhw_days_per_site <- lapply(names(events), function(site) {
  events[[site]]$climatology %>%
    filter(event) %>%  # Keep only rows where event == TRUE
    mutate(year = year(t)) %>%  # Extract the year from the date
    group_by(year) %>%
    summarize(mhw_days = n(), .groups = "drop") %>%  # Count MHW days per year
    mutate(site = site)  # Add site name for reference
})

# Combine results into a summary dataframe
mhw_summary <- bind_rows(mhw_days_per_site)















# Create names list separating temp and site
SST_site <- vector(mode = "list", length = 9)
names(SST_site) <- c("2","3","5","8","12","13","14","16","17")

SST_site[[1]] <- filter(temperature, site_id == "2") %>% 
  select(t, temp)
SST_site[[2]] <- filter(temperature, site_id == "3")%>% 
  select(t, temp)
SST_site[[3]] <- filter(temperature, site_id == "5")%>% 
  select(t, temp)
SST_site[[4]] <- filter(temperature, site_id == "8")%>% 
  select(t, temp)
SST_site[[5]] <- filter(temperature, site_id == "12")%>% 
  select(t, temp)
SST_site[[6]] <- filter(temperature, site_id == "13")%>% 
  select(t, temp)
SST_site[[7]] <- filter(temperature, site_id == "14")%>% 
  select(t, temp)
SST_site[[8]] <- filter(temperature, site_id == "16")%>% 
  select(t, temp)
SST_site[[9]] <- filter(temperature, site_id == "17")%>% 
  select(t, temp)


#site-level info
clim_site <- list()

for(i in 1:9){
  clim_site[[i]] <- ts2clm(SST_site[[i]], x=t, y=temp, pctile=90,
                           climatologyPeriod = c(min(SST_site[[i]]$t),max(SST_site[[i]]$t)))
  names(clim_site)[i] <- names(SST_site)[i]
  write.csv(clim_site[[i]], paste0("data/processed/climatology/",
                                   names(SST_site[i]), " _climatology.csv"))}


# Process events for all sites
events <- list()  # Initialize an empty list to store results
for(i in 1:9){
  site_name <- names(clim_site)[i]  # Get the site name for reference
  events[[site_name]] <- detect_event(clim_site[[i]], coldSpells = FALSE)  # Store results by site name
}


# Initialize an empty list to store results
mhw_days_per_site <- lapply(names(events), function(site) {
  # Extract climatology sub-list
  climatology_data <- events[[site]]$climatology
  
  # Summarize number of days with event == TRUE for each year
  climatology_data %>%
    filter(event) %>% # Only keep rows where event is TRUE
    mutate(year = lubridate::year(t)) %>% # Extract year from the date
    group_by(year) %>%
    summarize(mhw_days = n(), .groups = "drop") %>%
    mutate(site = site) # Add site name for reference
})

# Combine results into a single dataframe
mhw_summary <- bind_rows(mhw_days_per_site)



ggplot(mhw_summary, aes(x=year, y=mhw_days)) +
  geom_point(color = "red")+
  geom_smooth(color = "red", fill = "red")+
  coord_cartesian(ylim = c(0,150))+
  theme_classic()
         
         




#SCRAPS:




temp <- temperature %>% 
  select(date, mean) %>% 
  rename(t = date, 
         temp = mean)

ts <- ts2clm(temp, climatologyPeriod = c("2000-03-31", "2018-11-08"))
mhw <- detect_event(ts) 

mhw$event %>% 
  dplyr::ungroup() %>%
  dplyr::select(event_no, duration, date_start, date_peak, intensity_max, intensity_cumulative) %>% 
  dplyr::arrange(-intensity_max) %>% 
  head(5)


event_line(mhw, spread = 6000, 
           start_date = "2000-03-31", end_date = "2018-11-08")



#site-level
clim_site <- list()

for(i in 1:13){
  clim_site[[i]] <- ts2clm(SST_site[[i]], x=t, y=temp, pctile=90,
                           climatologyPeriod = c(min(SST_site[[i]]$t),max(SST_site[[i]]$t)))
  names(clim_site)[i] <- names(SST_site)[i]}



#ANALyze water temperature data across all sites

all_sites <- temperature %>% 
  group_by(t) %>% 
  summarize(temp = mean(temp))

ts <- ts2clm(all_sites, climatologyPeriod = c(min(all_sites$t),max(all_sites$t)))
mhw <- detect_event(ts)


event_line(mhw, spread = 12000, 
           #metric = "intensity_max", 
           #start_date = "1982-01-01", end_date = "2014-12-31"
)
lolli_plot(mhw, metric = "intensity_max")

event_line(mhw, spread = 800, 
           #metric = "intensity_max", 
           start_date = min(all_sites$t), 
           end_date = max(all_sites$t)
)


event_line(mhw, spread = 200, 
           #metric = "intensity_max", 
           start_date = min(all_sites$t), 
           end_date = max(all_sites$t)
)


mhw2 <- mhw$climatology %>% 
  arrange(t) %>% 
  slice(4660:6485)

ggplot(mhw2, aes(x = t, y = temp, y2 = thresh)) +
  geom_flame(n=5, n_gap = 2)+
  geom_line(aes(y = temp), linewidth = .3, color = "black",) +
  geom_line(aes(y = thresh), color = "darkgreen",size = 1.0) +
  geom_line(aes(y = seas),color = "blue", size = 1.2) +
  coord_cartesian(xlim = c(date("2013-06-01"), date("2017-01-01")))+
  theme_classic()



summary <- mhw$climatology %>% 
  mutate(year = as.numeric(year(t))) %>% 
  group_by(year) %>% 
  summarise(mhw_days = sum(event))

