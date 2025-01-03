##########################################################################
# Postelsia Project ######################################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 00: Load packages ###############################################
#-------------------------------------------------------------------------

# Part 1: Load Packages --------------------------------------------------

# Load packages
packages <- c("tidyverse", "mgcv", "ggthemes", "maps", "mapdata", "cowplot", "ggpubr", "sf", "gt")

pacman::p_load(packages, character.only = TRUE); rm(packages)
