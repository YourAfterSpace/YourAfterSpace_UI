import 'package:flutter/foundation.dart' show kIsWeb;

/// OAuth redirect URIs:
/// - Web: uses current origin (works in dev and in production).
/// - Mobile: custom scheme so the app opens again after sign-in.
String get _signInRedirectUri =>
    kIsWeb ? '${Uri.base.origin}/' : 'myapp://callback';
String get _signOutRedirectUri =>
    kIsWeb ? '${Uri.base.origin}/' : 'myapp://logout';

/// Amplify config. On web, redirect URIs match the app URL (localhost or production).
String get amplifyconfig => '''
{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "ap-south-1_UomOVMq5X",
            "AppClientId": "475r90pvbf1kle4u6dt188gi9i",
            "Region": "ap-south-1"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "OAuth": {
              "WebDomain": "ap-south-1uomovmq5x.auth.ap-south-1.amazoncognito.com",
              "AppClientId": "475r90pvbf1kle4u6dt188gi9i",
              "SignInRedirectURI": "$_signInRedirectUri",
              "SignOutRedirectURI": "$_signOutRedirectUri",
              "Scopes": [
                "openid",
                "email",
                "phone"
              ]
            }
          }
        }
      }
    }
  }
}
''';
