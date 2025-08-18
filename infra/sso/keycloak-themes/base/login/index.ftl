<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${properties.title!"Sign in to " + realm.displayName!realm.name}</title>
  <link rel="icon" type="image/png" href="${resourcesPath}/img/favicon.ico">
  <#if properties.styles?has_content>
    <#list properties.styles?split(' ') as style>
      <link href="${resourcesPath}/${style}" rel="stylesheet">
    </#list>
  </#if>
  <style>
    :root { --gap: 16px; }
    * { box-sizing: border-box; }
    html, body { height: 100%; margin: 0; font-family: system-ui, sans-serif; }
    .wrap { min-height: 100%; display: grid; place-items: center; padding: 24px; background: #0f1115; }
    .card { width: 100%; max-width: 420px; background: #181b22; color: #e6e8ef; border-radius: 14px; box-shadow: 0 8px 32px rgba(0,0,0,.35); padding: 28px; }
    .brand { display:flex; align-items:center; gap:12px; margin-bottom: 18px; }
    .brand img { height: 22px; }
    h1 { margin: 0 0 8px 0; font-size: 22px; }
    p.sub { margin: 0 0 20px 0; opacity: .7; font-size: 14px; }
    form { display: grid; gap: var(--gap); }
    label { display:block; font-size: 13px; margin-bottom: 6px; opacity: .9; }
    input[type="text"], input[type="password"] {
      width: 100%; padding: 12px 14px; border: 1px solid #2a2f3a; border-radius: 10px;
      background: #0f131a; color: #e6e8ef;
    }
    input[aria-invalid="true"] { border-color: #d64545; }
    .row { display:flex; align-items:center; justify-content: space-between; gap: 10px; }
    .checkbox { display:flex; align-items:center; gap: 8px; font-size: 13px; }
    .btn {
      width: 100%; padding: 12px 16px; border: 0; border-radius: 10px; background: #4b7cf5;
      color: white; font-weight: 600; cursor: pointer;
    }
    .links { display:flex; justify-content: space-between; gap: 10px; margin-top: 10px; font-size: 13px; }
    .links a { color: #9fb6ff; text-decoration: none; }
    .error, .msg { padding: 10px 12px; border-radius: 10px; font-size: 13px; }
    .error { background: #351b1b; color: #ffb3b3; border:1px solid #5a2b2b; }
    .msg { background: #1a2b1a; color: #c8f7c5; border:1px solid #294a29; }
    .social { margin-top: 18px; display:grid; gap:10px; }
    .social a { display:block; padding: 10px 12px; border-radius: 10px; border: 1px solid #2a2f3a; color:#e6e8ef; text-decoration:none; text-align:center; background:#10141b; }
    footer { margin-top: 18px; opacity: .5; font-size: 12px; text-align:center; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <div class="brand">
        <img src="${resourcesPath}/login/keycloak.v2/img/keycloak-logo-text.svg" alt="Keycloak">
      </div>

      <h1>${msg("doLogIn")! "Sign in"}</h1>
      <p class="sub">${realm.displayNameHtml!realm.displayName!realm.name}</p>

      <#-- Global messages -->
      <#if message?has_content>
        <div class="${(message.type!'') == 'error'?then('error','msg')}">${kcSanitize(message.summary)?no_esc}</div>
      </#if>

      <form id="kc-form-login" action="${url.loginAction}" method="post">
        <input type="hidden" name="credentialId" value="${auth.selectedCredential?if_exists}">

        <div>
          <label for="username">${msg("usernameOrEmail")! "Username or email"}</label>
          <input
            id="username"
            name="username"
            type="text"
            value="${(login.username!'')?html}"
            autocomplete="username"
            autofocus
            aria-invalid="${messagesPerField.existsError('username')?string('true','false')}"
          >
          <#if messagesPerField.existsError('username')>
            <div class="error" role="alert">${kcSanitize(messagesPerField.get('username'))?no_esc}</div>
          </#if>
        </div>

        <div>
          <label for="password">${msg("password")! "Password"}</label>
          <input
            id="password"
            name="password"
            type="password"
            autocomplete="current-password"
            aria-invalid="${messagesPerField.existsError('password')?string('true','false')}"
          >
          <#if messagesPerField.existsError('password')>
            <div class="error" role="alert">${kcSanitize(messagesPerField.get('password'))?no_esc}</div>
          </#if>
        </div>

        <div class="row">
          <#if realm.rememberMe?? && realm.rememberMe>
            <label class="checkbox">
              <input type="checkbox" name="rememberMe" id="rememberMe" <#if login.rememberMe?? && login.rememberMe>checked</#if>>
              ${msg("rememberMe")!"Remember me"}
            </label>
          </#if>

          <#if realm.resetPasswordAllowed>
            <a href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")!"Forgot password?"}</a>
          </#if>
        </div>

        <button class="btn" type="submit" id="kc-login">${msg("doLogIn")!"Sign in"}</button>

        <div class="links">
          <#if realm.registrationAllowed>
            <a href="${url.registrationUrl}">${msg("doRegister")!"Create account"}</a>
          </#if>
          <a href="${url.realmInfoUrl!'#'}">${msg("backToApplication")!"Back to app"}</a>
        </div>
      </form>

      <#-- Social providers -->
      <#if social?? && social.providers?has_content>
        <div class="social">
          <#list social.providers as p>
            <a href="${p.loginUrl}">${p.displayName}</a>
          </#list>
        </div>
      </#if>

      <footer>
        ${properties.footerText!"Keycloak"}
      </footer>
    </div>
  </div>

  <#if properties.scripts?has_content>
    <#list properties.scripts?split(' ') as s>
      <script src="${resourcesPath}/${s}"></script>
    </#list>
  </#if>
</body>
</html>
