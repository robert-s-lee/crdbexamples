_crdb_maps() {
  _crdb_maps_aws
  _crdb_maps_gcp
  _crdb_maps_azure
  _crdb_maps_others
}

# coordinates from https://www.cockroachlabs.com/docs/stable/enable-node-map.html
_crdb_maps_aws() {
  cat <<-EOF | awk '{print "upsert into system.locations VALUES (" $0" );"}' | cockroach sql --insecure --host ${_crdb_host:-127.0.0.1}
	'region', 'us-east-1', 37.478397, -76.453077
	'region', 'us-east-2', 40.417287, -76.453077
	'region', 'us-west-1', 38.837522, -120.895824
	'region', 'us-west-2', 43.804133, -120.554201
	'region', 'ca-central-1', 56.130366, -106.346771
	'region', 'eu-central-1', 50.110922, 8.682127
	'region', 'eu-west-1', 53.142367, -7.692054
	'region', 'eu-west-2', 51.507351, -0.127758
	'region', 'eu-west-3', 48.856614, 2.352222
	'region', 'ap-northeast-1', 35.689487, 139.691706
	'region', 'ap-northeast-2', 37.566535, 126.977969
	'region', 'ap-northeast-3', 34.693738, 135.502165
	'region', 'ap-southeast-1', 1.352083, 103.819836
	'region', 'ap-southeast-2', -33.86882, 151.209296
	'region', 'ap-south-1', 19.075984, 72.877656
	'region', 'sa-east-1', -23.55052, -46.633309
	EOF
}

# gcloud compute region list
_crdb_maps_gcp() {
  cat <<-EOF | awk '{print "upsert into system.locations VALUES (" $0" );"}' | cockroach sql --insecure --host ${_crdb_host:-127.0.0.1}
	'region', 'us-east1', 33.836082, -81.163727
	'region', 'us-east4', 37.478397, -76.453077
	'region', 'us-central1', 42.032974, -93.581543
	'region', 'us-west1', 43.804133, -120.554201
	'region', 'us-west2', 34.0522, -118.2437
	'region', 'northamerica-northeast1', 56.130366, -106.346771
	'region', 'europe-west1', 50.44816, 3.81886
	'region', 'europe-west2', 51.507351, -0.127758
	'region', 'europe-west3', 50.110922, 8.682127
	'region', 'europe-west4', 53.4386, 6.8355
	'region', 'europe-west6', 47.3769, 8.5417
	'region', 'asia-east1', 24.0717, 120.5624
	'region', 'asia-northeast1', 35.689487, 139.691706
	'region', 'asia-southeast1', 1.352083, 103.819836
	'region', 'australia-southeast1', -33.86882, 151.209296
	'region', 'asia-south1', 19.075984, 72.877656
	'region', 'southamerica-east1', -23.55052, -46.633309
	EOF
}

_crdb_maps_azure() {
  cat <<-EOF | awk '{print "upsert into system.locations VALUES (" $0" );"}' | cockroach sql --insecure --host ${_crdb_host:-127.0.0.1}
	'region', 'eastasia', 22.267, 114.188
	'region', 'southeastasia', 1.283, 103.833
	'region', 'centralus', 41.5908, -93.6208
	'region', 'eastus', 37.3719, -79.8164
	'region', 'eastus2', 36.6681, -78.3889
	'region', 'westus', 37.783, -122.417
	'region', 'northcentralus', 41.8819, -87.6278
	'region', 'southcentralus', 29.4167, -98.5
	'region', 'northeurope', 53.3478, -6.2597
	'region', 'westeurope', 52.3667, 4.9
	'region', 'japanwest', 34.6939, 135.5022
	'region', 'japaneast', 35.68, 139.77
	'region', 'brazilsouth', -23.55, -46.633
	'region', 'australiaeast', -33.86, 151.2094
	'region', 'australiasoutheast', -37.8136, 144.9631
	'region', 'southindia', 12.9822, 80.1636
	'region', 'centralindia', 18.5822, 73.9197
	'region', 'westindia', 19.088, 72.868
	'region', 'canadacentral', 43.653, -79.383
	'region', 'canadaeast', 46.817, -71.217
	'region', 'uksouth', 50.941, -0.799
	'region', 'ukwest', 53.427, -3.084
	'region', 'westcentralus', 40.890, -110.234
	'region', 'westus2', 47.233, -119.852
	'region', 'koreacentral', 37.5665, 126.9780
	'region', 'koreasouth', 35.1796, 129.0756
	'region', 'francecentral', 46.3772, 2.3730
	'region', 'francesouth', 43.8345, 2.1972
	EOF
}

_crdb_maps_others() {
  cat <<-EOF | awk '{print "upsert into system.locations VALUES (" $0" );"}' | cockroach sql --insecure --host ${_crdb_host:-127.0.0.1}
	'region', 'us-west2', 47.2343, -119.8526
	'region', 'us-central2', 33.0198, -96.6989
	EOF
}


