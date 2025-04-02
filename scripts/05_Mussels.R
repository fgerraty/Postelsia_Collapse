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
  mutate(period = factor(period, levels = c("pre_ssw", "post_ssw")))




ggplot(mussels, aes(x=tidal_elevation, fill = period))+
  geom_density(alpha = .6)

ggplot(mussels, aes(x=location, fill = period))+
  geom_density(alpha = .6)



f1 <- glmer(tidal_height~period + 1(x_transect)
            data = mussels)


model <- lmer(tidal_elevation ~ period + 
                (1 | site_id/x_transect), data = mussels)
summary(model)


ggplot(mussels, aes(x = period, y = tidal_elevation)) +
  geom_boxplot() +
  theme_minimal()


library(ggeffects)

preds <- ggpredict(model, terms = "period")  # Get predictions

ggplot(preds, aes(x = x, y = predicted)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2) +
  theme_minimal()


ggplot(mussels, aes(x = period)) +
  geom_jitter(width = 0.1, alpha = 0.3, aes(y = tidal_elevation)) + # Scatter with jitter
  geom_point(data = preds, aes(x = x, y = predicted), color = "red", size = 4) + 
  geom_errorbar(data = preds, aes(x = x, ymin = conf.low, ymax = conf.high), width = 0.2, color = "red") +
  theme_minimal()


