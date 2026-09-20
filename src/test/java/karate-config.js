function fn() {
  karate.configure('ssl', true); // enable
  var BaseUrl = 'https://petstore.swagger.io/'
  var baseUrlAut = ''
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);

  //credenciales
  var spotify_client_id = karate.properties['spotify-client-id'] || java.lang.System.getenv('SPOTIFY_CLIENT_ID');
  var spotify_client_secret = karate.properties['spotify-client-secret'] || java.lang.System.getenv('SPOTIFY_CLIENT_SECRET');
  var urlBaseSesion4 = karate.properties['sesion4.urlBase'] || 'http://localhost:8089';

  if (!env) {
    env = 'dev';
  }

  if (env == 'dev') {
    baseUrlAut = 'https://dummyjson.com'
    // customize
    // e.g. config.foo = 'bar';
  } else if (env == 'e2e') {
    baseUrlAut = 'https://dummyjson.com'
    // customize
  }

   var config = {
      env: env,
      BaseUrl: BaseUrl,
      baseUrlAut: baseUrlAut,
      baseUrlTokenSpotify: 'https://accounts.spotify.com',
      baseUrlSpotify: 'https://api.spotify.com',
      spotify_client_id:spotify_client_id,
      spotify_client_secret:spotify_client_secret,
      urlBaseSesion4:urlBaseSesion4,
      baseUrlRegres: 'https://reqres.in/api',
   }
  return config;
}
