#!/usr/local/bin/python3

# Import the driver
import sys
import csv

reader = csv.reader(sys.stdin)
for row in reader:
  print ("""INSERT INTO "fgyearbooktable01" (
	"commodity",
	"mkt_year",
	"reference_period",
	"reference_time_start",
	"reference_time_end",
	"observation_time",
	"planted_acreage_million_acres",
	"harvested_for_grain_million_acres",
	"production_million_bushels",
	"yield_per_harvested_acre_bushels_per_acre",
	"weighted_average_farm_price_dollars_per_bushel_low",
	"weighted_average_farm_price_dollars_per_bushel_high",
	"loan_rate_dollars_per_bushel")
SELECT
	'%s',
	'',
	'',
	'',
	'',
	'',
	%s,
	%s,
	%s,
	%s,
	%s,
	%s,
	'%s'::float
WHERE (SELECT((SELECT
	"planted_acreage_million_acres"=%s AND
	"harvested_for_grain_million_acres"=%s.017 AND
	"production_million_bushels"=%s.814 AND
	"yield_per_harvested_acre_bushels_per_acre"=%s.3 AND
	"weighted_average_farm_price_dollars_per_bushel_low"=%s.657 AND
	"weighted_average_farm_price_dollars_per_bushel_high"=%s.657 AND
	"loan_rate_dollars_per_bushel"='%s'::float
FROM "fgyearbooktable01"
WHERE "observation_time"<='2017-09-25T19:38:03.706626+00:00'::timestamptz AND "commodity"='Corn' AND "mkt_year"='1866/67' AND "reference_period"='1866/1867'
ORDER BY "observation_time" DESC LIMIT 1""" % ())
