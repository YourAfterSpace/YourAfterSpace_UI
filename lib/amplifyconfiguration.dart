const amplifyconfig = '''{
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "CognitoUserPool": {
          "Default": {
            "PoolId": "ap-south-1_UomOVMq5X",
            "AppClientId": "475r90pvbf1kle4u6dt188gi9i",
            "Region": "ap-south-1"
          }
        },
        
        "OAuth": {
            "WebDomain": "ap-south-1uomovmq5x.auth.ap-south-1.amazoncognito.com",
            "AppClientId": "475r90pvbf1kle4u6dt188gi9i",
            "SignInRedirectURI": "myapp://callback",
            "SignOutRedirectURI": "myapp://logout",
            "Scopes": [
              "openid",
              "email",
              "profile"
          ],
          "ResponseType": "code"
         }

      }
    }
  }
}''';
