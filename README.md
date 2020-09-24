Abe Solberg
FISH 6002: Final Data Project

Data Scraped on: 2020-09-23

Background:
This project is for the FISH 6002 Final Project.
The data were scraped from the Canadian Department of Fisheries & Oceans (DFO) Regional Statistics: Landings and Landed Values.
Data are yearly totals of Fisheries Landings, as reported by the DFO.
ALL Data should be considered preliminary and subject to revision

Data Sources Include: DMP (Dockside Monitoring Program), Hails, Logs, and Purchase Slips
Dataset includes landings from 2013 to 2020 for 32 Species.
Landings data from the following fisheries: Inshore, Midshore, Nearshore, Offshore

553 Observations, 17 Variables

Variables:

		1.year: <integer>

		2.family: <factor> Groundfish, Pelagics, Molluscs, Crustacean, Miscellaneous, Marine Mammals

		3.species_id: <integer>

		4.species: <factor> Cod, Atlantic, Haddock, Redfish, Halibut, Turbot/Greenland halibut, Flounders, Skate, Pollock, Hake, white, Cusk, Monkfish (Am angler), Grenadier, rough-head, Wolffish, Striped/ Atlantic, Herring, Atlantic, Mackerel, Tuna, bluefin, Eels, Capelin, Scallop, Sea, Whelks, Scallop, Iceland, Lobster, Shrimp, Pandalus Borealis, Crab, Queen/Snow, Shrimp, Pandalus Montagui, Groundfish Heads, Sea cucumber, Crab, rock, Squid, Illex, Crab, spider/toad, Seal skin, harp, unspecified (no.), Roe, lumpfish

		5.landed_wtround_lbs: <numeric>

		6.landed_wtround_kgs: <numeric>

		7.metric_tonnes_round_wt: <numeric>

		8.number_landed: <numeric>

		9.landed_value: <numeric>

		10.avg_value_per_lbs_num: <numeric>

		11.meta_id: <character>

		12.run_date: <Date>

		13.last_data_update: <POSIXct>

		14.landing_year: <factor> 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020

		15.vessel_length_category: <factor> All Vessels, Inshore: Vessels 0-34 ft. 11 in. (0-10.6m), Midshore: Vessels 65-99 ft. 11 in. (19.9-30.4m), Nearshore: Vessels 35-64 ft. 11 in. (10.7-19.8m), Offshore: Vessels > 100 ft. (30.5m)

		16.vessel_length: <factor> 0-10.6m, 19.9-30.4m, 10.7-19.8m, 30.5m

		17.shore_type: <factor> Inshore, Midshore, Nearshore, Offshore

NOTES FROM DFO:

	 1. Landings, catch and quota data will not always match one another for any number of reasons including (but not limited to); quota management cycles which differ from calendar year, hail information being used to report quotas prior to landings, different data sources not yet reconciled and delays in receiving documents from industry.
	 2. Flounders include American Plaice, Greysole, Yellowtail and Winter Flounder.
	 3. Landings for species which do not meet the DFO privacy threshold are aggregated as other in each species category.
