package asia.ivity.flutter.auth0_native;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.os.Handler;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.auth0.android.Auth0;
import com.auth0.android.Auth0Exception;
import com.auth0.android.authentication.AuthenticationAPIClient;
import com.auth0.android.authentication.AuthenticationException;
import com.auth0.android.authentication.PasswordlessType;
import com.auth0.android.authentication.storage.SecureCredentialsManager;
import com.auth0.android.authentication.storage.SharedPreferencesStorage;
import com.auth0.android.callback.BaseCallback;
import com.auth0.android.provider.AuthCallback;
import com.auth0.android.provider.VoidCallback;
import com.auth0.android.provider.WebAuthProvider;
import com.auth0.android.provider.WebAuthProvider.Builder;
import com.auth0.android.provider.WebAuthProvider.LogoutBuilder;
import com.auth0.android.request.AuthenticationRequest;
import com.auth0.android.request.ParameterizableRequest;
import com.auth0.android.result.Credentials;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.Map;

public class MethodCallHandlerImpl implements MethodCallHandler {
  private static final String TAG = "MethodCallHandlerImpl";

  public MethodCallHandlerImpl(
      Context applicationContext,
      Handler mainThreadHandler,
      OnCredentialsChangedListener onCredentialsChangedListener) {
    this.applicationContext = applicationContext;
    this.mainThreadHandler = mainThreadHandler;
    this.onCredentialsChangedListener = onCredentialsChangedListener;
  }

  private final Context applicationContext;
  private final Handler mainThreadHandler;
  private final OnCredentialsChangedListener onCredentialsChangedListener;

  @Nullable private Activity activity;

  private Auth0 account;
  private SecureCredentialsManager credentialsManager;
  private AuthenticationAPIClient apiClient;

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    switch (call.method) {
      case "initialize":
        handleInitialize(call, result);
        break;
      case "login":
        handleLogin(call, result);
        break;
      case "logout":
        handleLogout(call, result);
        break;
      case "hasCredentials":
        handleHasCredentials(result);
        break;
      case "passwordlessWithSMS":
        handlePasswordlessWithSMS(call, result);
        break;
      case "loginWithPhoneNumber":
        handleLoginWithPhoneNumber(call, result);
        break;
      case "passwordlessWithEmail":
        handlePasswordlessWithEmail(call, result);
        break;
      case "loginWithEmail":
        handleLoginWithEmail(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void handleInitialize(MethodCall call, final Result result) {
    final String clientId = call.argument("clientId");
    final String domain = call.argument("domain");
    final Boolean oidc = call.argument("oidc");
    final Boolean loggingEnabled = call.argument("loggingEnabled");

    account = new Auth0(clientId, domain);
    account.setOIDCConformant(oidc);
    account.setLoggingEnabled(loggingEnabled);

    apiClient = new AuthenticationAPIClient(account);

    credentialsManager =
        new NotifyingSecureCredentialsManager(
            applicationContext,
            new AuthenticationAPIClient(account),
            new SharedPreferencesStorage(applicationContext),
            onCredentialsChangedListener);

    result.success(null);
  }

  private void handleLogin(MethodCall call, final Result result) {
    if (activity == null) {
      result.error("activity-null", "", "");
      return;
    }

    Builder builder = WebAuthProvider.login(account);

    final String audience = call.argument("audience");
    if (audience != null) {
      builder = builder.withAudience(audience);
    }

    final String connection = call.argument("connection");
    if (connection != null) {
      builder = builder.withConnection(connection);
    }

    final String scheme = call.argument("scheme");
    if (scheme != null) {
      builder = builder.withScheme(scheme);
    }

    final String scope = call.argument("scope");
    if (scope != null) {
      builder = builder.withScope(scope);
    }

    builder.start(
        activity,
        new AuthCallback() {
          @Override
          public void onFailure(@NonNull Dialog dialog) {
            mainThreadHandler.post(() -> result.error("failed-show-dialog", "", ""));
          }

          @Override
          public void onFailure(AuthenticationException exception) {
            mainThreadHandler.post(
                () -> result.error("failed-exception", exception.getMessage(), ""));
          }

          @Override
          public void onSuccess(@NonNull Credentials credentials) {
            credentialsManager.saveCredentials(credentials);

            mainThreadHandler.post(() -> result.success(Mappers.mapCredentials(credentials)));
          }
        });
  }

  private void handleLogout(MethodCall call, final Result result) {
    if (activity == null) {
      result.error("activity-null", "", "");
      return;
    }

    LogoutBuilder builder = WebAuthProvider.logout(account);

    final String scheme = call.argument("scheme");
    if (scheme != null) {
      builder = builder.withScheme(scheme);
    }

    builder.start(
        activity,
        new VoidCallback() {
          @Override
          public void onSuccess(Void payload) {
            credentialsManager.clearCredentials();
            mainThreadHandler.post(() -> result.success(null));
          }

          @Override
          public void onFailure(Auth0Exception error) {
            mainThreadHandler.post(() -> result.error("failed-exception", error.getMessage(), ""));
          }
        });
  }

  private void handleHasCredentials(final Result result) {
    result.success(credentialsManager.hasValidCredentials());
  }

  private void handlePasswordlessWithSMS(MethodCall call, final Result result) {
    final String phone = call.argument("phone");
    final PasswordlessType type = parsePasswordlessType(call.argument("type"));
    final String connection = call.argument("connection");

    apiClient
        .passwordlessWithSMS(phone, type, connection)
        .start(
            new BaseCallback<Void, AuthenticationException>() {
              @Override
              public void onSuccess(Void payload) {
                mainThreadHandler.post(() -> result.success(null));
              }

              @Override
              public void onFailure(AuthenticationException error) {
                mainThreadHandler.post(
                    () -> result.error("failed-exception", error.getMessage(), ""));
              }
            });
  }

  private void handleLoginWithPhoneNumber(MethodCall call, final Result result) {
    final String phone = call.argument("phone");
    final String code = call.argument("code");
    final String connection = call.argument("connection");

    AuthenticationRequest request = apiClient.loginWithPhoneNumber(phone, code, connection);

    final String audience = call.argument("audience");
    if (audience != null) {
      request = request.setAudience(audience);
    }
    final String scope = call.argument("scope");
    if (scope != null) {
      request = request.setScope(scope);
    }
    final Map<String, Object> parameters = call.argument("parameters");
    if (parameters != null) {
      request = request.addAuthenticationParameters(parameters);
    }

    request.start(
        new BaseCallback<Credentials, AuthenticationException>() {
          @Override
          public void onSuccess(Credentials payload) {
            credentialsManager.saveCredentials(payload);

            mainThreadHandler.post(() -> result.success(Mappers.mapCredentials(payload)));
          }

          @Override
          public void onFailure(AuthenticationException error) {
            mainThreadHandler.post(() -> result.error("failed-exception", error.getMessage(), ""));
          }
        });
  }

  private void handlePasswordlessWithEmail(MethodCall call, final Result result) {
    final String email = call.argument("email");
    final PasswordlessType type = parsePasswordlessType(call.argument("type"));
    final String connection = call.argument("connection");

    ParameterizableRequest<Void, AuthenticationException> request =
        apiClient.passwordlessWithEmail(email, type, connection);

    request.start(
        new BaseCallback<Void, AuthenticationException>() {
          @Override
          public void onSuccess(Void payload) {
            mainThreadHandler.post(() -> result.success(null));
          }

          @Override
          public void onFailure(AuthenticationException error) {
            mainThreadHandler.post(() -> result.error("failed-exception", error.getMessage(), ""));
          }
        });
  }

  private void handleLoginWithEmail(MethodCall call, final Result result) {
    final String email = call.argument("email");
    final String code = call.argument("code");
    final String connection = call.argument("connection");

    AuthenticationRequest request = apiClient.loginWithEmail(email, code, connection);

    final String audience = call.argument("audience");
    if (audience != null) {
      request = request.setAudience(audience);
    }
    final String scope = call.argument("scope");
    if (scope != null) {
      request = request.setScope(scope);
    }
    final Map<String, Object> parameters = call.argument("parameters");
    if (parameters != null) {
      request = request.addAuthenticationParameters(parameters);
    }

    request.start(
        new BaseCallback<Credentials, AuthenticationException>() {
          @Override
          public void onSuccess(Credentials payload) {
            credentialsManager.saveCredentials(payload);

            mainThreadHandler.post(() -> result.success(Mappers.mapCredentials(payload)));
          }

          @Override
          public void onFailure(AuthenticationException error) {
            mainThreadHandler.post(() -> result.error("failed-exception", error.getMessage(), ""));
          }
        });
  }

  private PasswordlessType parsePasswordlessType(String type) {
    switch (type) {
      case "code":
        return PasswordlessType.CODE;
      case "android_link":
        return PasswordlessType.ANDROID_LINK;
      case "web_link":
        return PasswordlessType.WEB_LINK;
    }

    Log.e(TAG, "Invalid passwordless type: " + type);
    return PasswordlessType.CODE;
  }

  void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }
}
