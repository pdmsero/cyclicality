rm(list=ls())

library(dplyr)
library(foreign)
library(gdata)
library(plm)
library(readxl)
library("rstudioapi")
library(stringr)

setwd(dirname(getActiveDocumentContext()$path))

#### GDP Data ####

# Load the data file for GDP
GDP <- read_excel("Data/Section1All_xls.xlsx",sheet = "T10105-A")

GDP<-GDP[-6:-1,]
GDP <- GDP[-1]
GDP <- GDP[-2]
GDP<-t(GDP)
colnames(GDP) <- GDP[1,]
GDP <- GDP[-1, ]
colnames(GDP)[1] <- "Year"
rownames(GDP)<-GDP[,1]
GDP <-data.frame(GDP)
GDP <- GDP[, !names(GDP) %in% c("GDP")]
GDP  <- GDP  %>% mutate_if(is.character, as.numeric)

# Load the data file for GDP
pGDP <- read_excel("Data/Section1All_xls.xlsx",sheet = "T10104-A")

pGDP <-pGDP[-6:-1,]
pGDP <- pGDP[-1]
pGDP <- pGDP[-2]
pGDP <-t(pGDP)
colnames(pGDP) <- pGDP[1,]
pGDP <- pGDP[-1, ]
colnames(pGDP)[1] <- "Year"
rownames(pGDP)<-pGDP[,1]
pGDP <-data.frame(pGDP)
pGDP <- pGDP[, !names(pGDP) %in% c("pGDP")]
pGDP  <- pGDP  %>% mutate_if(is.character, as.numeric)

rGDP<-GDP/pGDP
rGDP$Year<-GDP$Year

# Set the time series index
ts <- ts(GDP$Year, frequency = 1, start = c(min(GDP$Year), 1))
GDP.ts <- ts(GDP, frequency = 1, start = c(min(GDP$Year), 1))
pGDP.ts <- ts(pGDP, frequency = 1, start = c(min(pGDP$Year), 1))
rGDP.ts <- ts(rGDP, frequency = 1, start = c(min(pGDP$Year), 1))

# Calculate variables
dGDP.ts <- diff(log(GDP.ts))
dpGDP.ts <- diff(log(pGDP.ts))
drGDP.ts <- diff(log(rGDP.ts))

dGDP.ts[,1]<-GDP.ts[2:nrow(GDP.ts),1]
dpGDP.ts[,1]<-GDP.ts[2:nrow(GDP.ts),1]
drGDP.ts[,1]<-GDP.ts[2:nrow(GDP.ts),1]

keep(dGDP.ts, dpGDP.ts, drGDP.ts, sure = TRUE)

# Load the Stata dataset
# Replace the file path with the correct one on your system
NBER_MP <- read.csv("Data/nberces5818v1_n2012.csv")

test<-read.dta("Data/NBER_EXPORTS_RawFile.dta")
test1<-read.dta("Data/Exports.dta")
test2<-read.dta("Data/[1]_RND_Industry_data_final.dta")

# Set up the panel data structure

pdata <- pdata.frame(NBER_MP, index=c("naics", "year"))

# Calculate variables
pdata$r_vadd <- pdata$vadd / pdata$piship
pdata$r_vship <- pdata$vship / pdata$piship
# pdata$r_exports <- pdata$exports / pdata$piship
pdata$d_vadd <- log(pdata$r_vadd) - log(lag(pdata$r_vadd))
pdata$d_vship <- log(pdata$r_vship) - log(lag(pdata$r_vship))
# pdata$d_exports <- log(pdata$r_exports) - log(lag(pdata$r_exports))

# Drop variables
pdata <- subset(pdata, select=-c(emp_ind, pay, prode, prodh, prodw, matcost, invest, invent, energy, cap, equip, plant, pimat, pien, r_vadd, r_vship, r_exports))

# Save the dataset
# Replace the file path with the correct one on your system
write.dta(pdata, "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/NBER_EXPORTS.dta")
