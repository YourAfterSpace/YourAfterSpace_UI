# CORS setup for Flutter web and API

## Why you see errors in the browser but not in Postman

- **Postman** is not a browser: it does not enforce CORS, so requests work.
- **Chrome (Flutter web)** runs your app at `http://localhost:3001`. When it calls your API at `https://ebg1xd8fv9.execute-api.ap-south-1.amazonaws.com/...`, the browser sends a **preflight** `OPTIONS` request first. The API **must** respond with specific headers, or the browser blocks the real request and you see:
  - `blocked by CORS policy`
  - `No 'Access-Control-Allow-Origin' header is present on the requested resource`

The fix is on the **backend / API Gateway**, not in the Flutter app.

---

## What the API must return

### 1. Response to OPTIONS (preflight)

For every path your app calls (e.g. `/second/v1/user/profile`, `/second/v1/experiences/all`), the server must respond to **OPTIONS** with status **200** and at least:

| Header | Example value |
|--------|----------------|
| `Access-Control-Allow-Origin` | `http://localhost:3001` (or `*` for any origin) |
| `Access-Control-Allow-Methods` | `GET, POST, PUT, OPTIONS` |
| `Access-Control-Allow-Headers` | `Content-Type, x-amzn-oidc-identity` |
| `Access-Control-Max-Age` | `86400` (optional) |

### 2. Response to GET / POST / PUT (actual requests)

Every real response must also include:

| Header | Example value |
|--------|----------------|
| `Access-Control-Allow-Origin` | `http://localhost:3001` (or `*`) |

So the browser sees that the response is allowed for your origin.

---

## AWS API Gateway (REST API)

1. Open **API Gateway** → your API (e.g. the one with `ebg1xd8fv9`).
2. **Enable CORS** for the resources/methods your app uses:
   - Select the resource (e.g. `/v1/user/profile` or the proxy resource under `/second`).
   - **Actions** → **Enable CORS**.
   - Set:
     - **Access-Control-Allow-Origin**: `http://localhost:3001` (for local web). For production, add your real origin (e.g. `https://your-app.domain.com`) or use a comma-separated list if the UI allows, or configure via gateway response.
     - **Access-Control-Allow-Headers**: `Content-Type,x-amzn-oidc-identity`
     - **Access-Control-Allow-Methods**: `GET,POST,PUT,OPTIONS`
   - Save and **Deploy** the API to your stage (e.g. the stage used in the URL).

3. If you use a **proxy resource** (e.g. `/second` → Lambda or HTTP integration), enable CORS on that resource and ensure the **integration** (Lambda/backend) also returns the same CORS headers on **real** responses (GET/POST/PUT). API Gateway can add headers in **Gateway Responses** (e.g. for 4xx/5xx) and in **Method Response** / **Integration Response** for 200.

4. **Gateway Responses** (optional but useful):  
   API Gateway → your API → **Gateway Responses** → edit **Default 4XX** and **Default 5XX** → add header `Access-Control-Allow-Origin` = `http://localhost:3001` (and optionally other CORS headers) so errors also allow the browser to read the response.

---

## Backend (Lambda / Spring Boot behind API Gateway)

- If the actual response is from **Lambda**: the Lambda response object must include headers, e.g.  
  `headers: { "Access-Control-Allow-Origin": "http://localhost:3001" }` (and any other CORS headers you need).
- If the backend is **Spring Boot** behind API Gateway, add CORS in the app, e.g.:

```java
@Configuration
public class CorsConfig {
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")
                    .allowedOrigins("http://localhost:3001", "https://your-production-origin.com")
                    .allowedMethods("GET", "POST", "PUT", "OPTIONS")
                    .allowedHeaders("Content-Type", "x-amzn-oidc-identity");
            }
        };
    }
}
```

Then ensure API Gateway forwards the request to the backend and returns the backend’s response (with CORS headers) to the client.

---

## Headers the Flutter app sends

The app already sends the user id in the header expected by your backend:

- **Header name:** `x-amzn-oidc-identity`
- **Value:** Cognito user sub (from Amplify Auth)

So once CORS is fixed on the API/backend, the same requests that work in Postman (with `x-amzn-oidc-identity` set) will work from the browser.

---

## Workaround while fixing CORS: run on a non-browser device

Browsers enforce CORS; mobile and desktop apps do not. To test against the real API without changing the server:

```bash
# Windows
flutter run -d windows

# Android
flutter run -d android
```

Use the same base URL; only the browser blocks cross-origin requests.
