package asia.ivity.flutter.auth0_native;

import android.content.Context;
import androidx.annotation.NonNull;
import com.auth0.android.authentication.AuthenticationAPIClient;
import com.auth0.android.authentication.storage.CredentialsManagerException;
import com.auth0.android.authentication.storage.SecureCredentialsManager;
import com.auth0.android.authentication.storage.Storage;
import com.auth0.android.callback.BaseCallback;
import com.auth0.android.result.Credentials;

class NotifyingSecureCredentialsManager extends SecureCredentialsManager {
  /**
   * Creates a new SecureCredentialsManager to handle Credentials
   *
   * @param context a valid context
   * @param apiClient the Auth0 Authentication API Client to handle token refreshment when needed.
   * @param storage the storage implementation to use
   */
  NotifyingSecureCredentialsManager(
      @NonNull Context context,
      @NonNull AuthenticationAPIClient apiClient,
      @NonNull Storage storage,
      @NonNull OnCredentialsChangedListener changedListener) {
    super(context, apiClient, storage);

    this.onCredentialsChangedListener = changedListener;

    loadInitialValue();
  }

  private final OnCredentialsChangedListener onCredentialsChangedListener;

  @Override
  public void saveCredentials(@NonNull Credentials credentials) throws CredentialsManagerException {
    super.saveCredentials(credentials);

    onCredentialsChangedListener.onCredentialsChanged(credentials);
  }

  @Override
  public void clearCredentials() {
    super.clearCredentials();

    onCredentialsChangedListener.onCredentialsChanged(null);
  }

  private void loadInitialValue() {
    getCredentials(
        new BaseCallback<Credentials, CredentialsManagerException>() {
          @Override
          public void onSuccess(Credentials payload) {
            onCredentialsChangedListener.onCredentialsChanged(payload);
          }

          @Override
          public void onFailure(CredentialsManagerException error) {
            onCredentialsChangedListener.onCredentialsChanged(null);
          }
        });
  }
}
