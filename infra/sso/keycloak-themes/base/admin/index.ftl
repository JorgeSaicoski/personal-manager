<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${properties.title!"Keycloak Admin Console"}</title>
    <link rel="icon" type="image/png" href="${resourcesPath}/img/favicon.ico">
    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${resourcesPath}/${style}" rel="stylesheet">
        </#list>
    </#if>
    <style>
        body, html { margin: 0; padding: 0; height: 100%; }
        .container { height: 100vh; display: flex; flex-direction: column; }
        .loading { 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            height: 100vh; 
            font-family: sans-serif;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="loading">
            <div>Loading Admin Console...</div>
        </div>
    </div>
    
    <script>
        // Basic admin console initialization
        window.keycloakAdminConsole = {
            authUrl: '${authUrl}',
            resourceUrl: '${resourceUrl}',
            masterRealm: '${masterRealm}',
            resourceVersion: '${resourceVersion}'
        };
        
        // Simple redirect to actual admin console
        window.location.href = '${authUrl}/admin/';
    </script>
</body>
</html>