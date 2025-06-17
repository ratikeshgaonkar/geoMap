public class MapDataToSend {

	public class Payload{
		public Double latitude;
		public Double longitude;
	}

	public class LocationResponse {
        public List<Result> results;
        public String status;
    }

    public class Result {
        public String formatted_address;
    }

	@AuraEnabled
	public static String geoMap(){
		list<Account> locationWeWant = [SELECT location__Latitude__s,location__Longitude__s FROM Account WHERE Id = '001WU00000Nf5GfYAJ'];

		//prepare payload
		payload data = new payload();
		data.latitude = locationWeWant[0].location__Latitude__s;
		data.longitude = locationWeWant[0].location__Longitude__s;
		System.debug('data.longitude: ' + data.longitude);
		System.debug('data.latitude: ' + data.latitude);

		//GET Request 
		String apiKey  = 'AIzaSyCitkdxGRT4QS1qML3J5pyGNWz20qEQNdE';
		String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='
                        + data.latitude + ',' + data.longitude + '&key=' + apiKey;
		System.debug('Endpoint: ' + endpoint);
		Http http  = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setMethod('GET');
		
		try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                LocationResponse locResp = (LocationResponse) JSON.deserialize(response.getBody(), LocationResponse.class);
                if (locResp.results != null && !locResp.results.isEmpty()) {
                    return locResp.results[0].formatted_address;
                } else {
                    return 'No address found for these coordinates.';
                }
            } else {
                return 'Google Maps API error: ' + response.getStatusCode();
            }
        } catch (Exception e) {
            return 'Callout failed: ' + e.getMessage();
        }
	}
}