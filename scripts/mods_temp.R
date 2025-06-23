#------------------------------
# Postelsia Linear Modeling ###
#------------------------------
library(lme4)
library(lmerTest)
library(emmeans)
set.seed(99)


ggplot(postelsia_annual_summary, aes(x=density))+
  geom_histogram()

temp <- postelsia_annual_summary %>% 
        mutate(density = if_else(density == 0, .001, density))

temp2 <- stars_summary %>% 
  filter(year>2009)

##########################
# Density as response ####
##########################

#LMER####

f1 <- lmer(density ~ period2 + 
                (1 | site_id),
              data = postelsia_annual_summary)
summary(f1)

# Check assumptions with DHARMa package
f1_res = simulateResiduals(f1, quantreg=T)
plot(f1_res, rank = T)
testDispersion(f1_res)
plotResiduals(f1_res, postelsia_annual_summary$site_id, xlab = "Site", main=NULL)


#GLMER Gaussian ####
f2 <- glmmTMB(density ~ period2 + 
                 (1 | site_id),
               family = gaussian, 
               data = postelsia_annual_summary)
summary(f2)

# Check assumptions with DHARMa package
f2_res = simulateResiduals(f2, quantreg=T)
plot(f2_res, rank = T)
testDispersion(f2_res)
plotResiduals(f2_res, postelsia_annual_summary$site_id, xlab = "Site", main=NULL)


#GLMER tweedie
f3 <- glmmTMB(density ~ period2 + 
                (1 | site_id),
              family = tweedie, 
              data = postelsia_annual_summary)
summary(f3)

# Check assumptions with DHARMa package
f3_res = simulateResiduals(f3, quantreg=T)
plot(f3_res, rank = T)
testDispersion(f3_res)
plotResiduals(f3_res, postelsia_annual_summary$site_id, xlab = "Site", main=NULL)


#GLMER lognormal
f4 <- glmmTMB(density ~ period2 + 
                (1 | site_id),
              family = lognormal, 
              data = temp)
summary(f4)

# Check assumptions with DHARMa package
f4_res = simulateResiduals(f4, quantreg=T)
plot(f4_res, rank = T)
testDispersion(f4_res)
plotResiduals(f4_res, postelsia_annual_summary$site_id, xlab = "Site", main=NULL)


#GLMER gamma
f5 <- glmmTMB(density ~ period2 + 
                (1 | site_id),
              family = Gamma, 
              data = temp)
summary(f5)

 #Throwing errors!


emmeans(f1, specs = "period2", type = "response")
emmeans(f2, specs = "period2", type = "response")
emmeans(f3, specs = "period2", type = "response")
emmeans(f4, specs = "period2", type = "response")
emmeans(f5, specs = "period2", type = "response")


#################################
# Percent of max as response ####
#################################

#LMER####
g1 <- lmer(percent_of_max ~ period2 + 
             (1 | site_id),
           data = postelsia_annual_summary)
summary(g1)

# Check assumptions with DHARMa package
g1_res = simulateResiduals(g1, quantreg=T)
plot(g1_res, rank = T)
testDispersion(g1_res)
plotResiduals(g1_res, postelsia_annual_summary$site_id, xlab = "Site", main=NULL)

#GLMER Gaussian ####
g2 <- glmmTMB(percent_of_max ~ period2 + 
                (1 | site_id),
              family = gaussian, 
              data = postelsia_annual_summary)
summary(g2)

# Check assumptions with DHARMa package
g2_res = simulateResiduals(g2, quantreg=T)
plot(g2_res, rank = T)
testDispersion(g2_res)
plotResiduals(g2_res, postelsia_annual_summary$site_id, xlab = "Site", main=NULL)


#GLMER tweedie
g3 <- glmmTMB(percent_of_max ~ period2 + 
                (1 | site_id),
              family = tweedie, 
              data = postelsia_annual_summary)
summary(g3)

# Check assumptions with DHARMa package
g3_res = simulateResiduals(g3, quantreg=T)
plot(g3_res, rank = T)
testDispersion(g3_res)
plotResiduals(g3_res, postelsia_annual_summary$site_id, xlab = "Site", main=NULL)


emmeans(g1, specs = "period2", type = "response")
emmeans(g2, specs = "period2", type = "response")
emmeans(g3, specs = "period2", type = "response")



#------------------------------
# Pisaster Linear Modeling ###
#------------------------------

#LMER####

h1 <- lmer(pisaster_biomass_g ~ period + 
             (1 | site_id),
           data = stars_summary)
summary(h1)

# Check assumptions with DHARMa package
h1_res = simulateResiduals(h1)
plot(h1_res, rank = T)
testDispersion(h1_res)
plotResiduals(h1_res, stars_summary$site_id, xlab = "Site", main=NULL)


#GLMER Gaussian ####
h2 <- glmmTMB(pisaster_biomass_g ~ period + 
                (1 | site_id),
              family = gaussian, 
              data = stars_summary)
summary(h2)

# Check assumptions with DHARMa package
h2_res = simulateResiduals(h2, quantreg=T)
plot(h2_res, rank = T)
testDispersion(h2_res)
plotResiduals(h2_res, stars_summary$site_id, xlab = "Site", main=NULL)


#GLMER tweedie
h3 <- glmmTMB(pisaster_biomass_g ~ period + 
                (1 | site_id),
              family = tweedie, 
              data = stars_summary)
summary(h3)

# Check assumptions with DHARMa package
h3_res = simulateResiduals(h3, quantreg=T)
plot(h3_res, rank = T)
testDispersion(h3_res)
plotResiduals(h3_res, stars_summary$site_id, xlab = "Site", main=NULL)


#GLMER lognormal
h4 <- glmmTMB(pisaster_biomass_g ~ period + 
                (1 | site_id),
              family = lognormal, 
              data = stars_summary)
summary(f4)

# Check assumptions with DHARMa package
h4_res = simulateResiduals(h4, quantreg=T)
plot(h4_res, rank = T)
testDispersion(h4_res)
plotResiduals(h4_res, stars_summary$site_id, xlab = "Site", main=NULL)


#GLMER gamma
h5 <- glmmTMB(pisaster_biomass_g ~ period + 
                (1 | site_id),
              family = Gamma(link = "log"), 
              data = stars_summary)
summary(h5)

# Check assumptions with DHARMa package
h5_res = simulateResiduals(h5, quantreg=T)
plot(h5_res, rank = T)
testDispersion(h5_res)
plotResiduals(h5_res, stars_summary$site_id, xlab = "Site", main=NULL)


emmeans(h1, specs = "period", type = "response")
emmeans(h2, specs = "period", type = "response")
emmeans(h3, specs = "period", type = "response")
emmeans(h4, specs = "period", type = "response")
emmeans(h5, specs = "period", type = "response")



#################################
# Percent of max as response ####
#################################

#LMER####
i1 <- lmer(percent_of_max ~ period + 
             (1 | site_id),
           data = stars_summary)
summary(i1)

# Check assumptions with DHARMa package
i1_res = simulateResiduals(i1)
plot(i1_res, rank = T)
testDispersion(i1_res)
plotResiduals(i1_res, stars_summary$site_id, xlab = "Site", main=NULL)

#GLMER Gaussian ####
i2 <- glmmTMB(percent_of_max ~ period + 
                (1 | site_id),
              family = gaussian, 
              data = stars_summary)
summary(i2)

# Check assumptions with DHARMa package
i2_res = simulateResiduals(i2, quantreg=T)
plot(i2_res, rank = T)
testDispersion(i2_res)
plotResiduals(i2_res, stars_summary$site_id, xlab = "Site", main=NULL)


#GLMER tweedie
i3 <- glmmTMB(percent_of_max ~ period + 
                (1 | site_id),
              family = tweedie, 
              data = stars_summary)
summary(i3)

# Check assumptions with DHARMa package
i3_res = simulateResiduals(i3, quantreg=T)
plot(i3_res, rank = T)
testDispersion(i3_res)
plotResiduals(i3_res, stars_summary$site_id, xlab = "Site", main=NULL)

#GLMER lognormal
i4 <- glmmTMB(percent_of_max ~ period + 
                (1 | site_id),
              family = lognormal, 
              data = stars_summary)
summary(i4)

# Check assumptions with DHARMa package
i4_res = simulateResiduals(i4, quantreg=T)
plot(i4_res, rank = T)
testDispersion(i4_res)
plotResiduals(i4_res, stars_summary$site_id, xlab = "Site", main=NULL)


#GLMER gamma
i5 <- glmmTMB(percent_of_max ~ period + 
                (1 | site_id),
              family = Gamma(link = "log"), 
              data = stars_summary)
summary(i5)

# Check assumptions with DHARMa package
i5_res = simulateResiduals(i5, quantreg=T)
plot(i5_res, rank = T)
testDispersion(i5_res)
plotResiduals(i5_res, stars_summary$site_id, xlab = "Site", main=NULL)


emmeans(i1, specs = "period", type = "response")
emmeans(i2, specs = "period", type = "response")
emmeans(i3, specs = "period", type = "response")
emmeans(i4, specs = "period", type = "response")
emmeans(i5, specs = "period", type = "response")
