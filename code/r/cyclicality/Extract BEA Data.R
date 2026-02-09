library(bea.R)

beaKey 	<- '3499571E-CBA7-4F46-928D-7D358CC4D4B7'

beaSpecs <- list(
  'UserID' = beaKey ,
  'Method' = 'GetData',
  'datasetname' = 'GDPbyIndustry',
  'TableName' = 'T20305',
  'Frequency' = 'A',
  'Year' = '2011',
  'ResultFormat' = 'json'
);
beaPayload <- beaGet(beaSpecs);

beaStatTab <- beaGet(beaSpecs, iTableStyle = FALSE)

beaLong <- beaGet(beaSpecs, asWide = FALSE)

beaStatTab <- beaGet(beaSpecs, iTableStyle = FALSE)

{"DatasetName":"NIPA","DatasetDescription":"Standard NIPA tables"}
{"DatasetName":"NIUnderlyingDetail","DatasetDescription":"Standard NI underlying detail tables"}
{"DatasetName":"MNE","DatasetDescription":"Multinational Enterprises"}
{"DatasetName":"FixedAssets","DatasetDescription":"Standard Fixed Assets tables"}
{"DatasetName":"ITA","DatasetDescription":"International Transactions Accounts"}
{"DatasetName":"IIP","DatasetDescription":"International Investment Position"}
{"DatasetName":"InputOutput","DatasetDescription":"Input-Output Data"}
{"DatasetName":"IntlServTrade","DatasetDescription":"International Services Trade"}
{"DatasetName":"IntlServSTA","DatasetDescription":"International Services Supplied Through Affiliates"}
{"DatasetName":"GDPbyIndustry","DatasetDescription":"GDP by Industry"}
{"DatasetName":"Regional","DatasetDescription":"Regional data sets"}
{"DatasetName":"UnderlyingGDPbyIndustry","DatasetDescription":"Underlying GDP by Industry"}
{"DatasetName":"APIDatasetMetaData","DatasetDescription":"Metadata about other API datasets"}