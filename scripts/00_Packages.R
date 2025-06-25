##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 00: Load packages ###############################################
#-------------------------------------------------------------------------

# Part 1: Load Packages --------------------------------------------------

# Load packages
packages <- c("tidyverse", "mgcv", "glmmTMB", "DHARMa", "lqmm", "heatwaveR", 
              "lme4", "lmerTest", "emmeans", "ggthemes", "maps", "mapdata", 
              "cowplot", "ggpubr", "sf", "gt", "gratia",  "biscale")

pacman::p_load(packages, character.only = TRUE); rm(packages)
