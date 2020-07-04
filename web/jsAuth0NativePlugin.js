class auth0 {
  /// get the Auth0 script for CDN
  $.getScript('https://cdn.auth0.com/js/auth0/9.11/auth0.min.js', function()
    {

    /// call to handle the initialization of Auth0
    auth0Initialize(clientId,domain) async {

      var webAuth = new auth0.WebAuth({
          domain:       domain,
          clientID:     clientId
        });
    }

    // Handle logout
    logOut() async {
        const fetchAuthConfig = () => fetch("/auth_config.json");
        const response = await fetchAuthConfig();
        const config = await response.json();

        auth0.logout({
                    returnTo: config.redirectUri.,
                    client_id: config.clientId
                  });
    }

    // returns bool on if there are valid credentials
    isAuthenticated(){
        const isAuthenticated = await auth0.isAuthenticated();

        return isAuthenticated;
    }

    // starts the universal login
    databaseLogin() async {
         const fetchAuthConfig = () => fetch("/auth_config.json");
         const response = await fetchAuthConfig();
         const config = await response.json();

         var url = webAuth.client.buildAuthorizeUrl({
             clientID: config.clientId, // string
             responseType: 'token', // code or token
             redirectUri: config.redirectUri,
             scope: 'openid profile email',
           });
    }



    passwordlessWithSMS(){
         webAuth.passwordlessStart({
              connection: 'sms',
              send: 'code',
              phoneNumber: 'USER_PHONE_NUMBER'
            }, function (err,res) {

            }
    }

    loginWithPhoneNumber(){

    }


 });

}