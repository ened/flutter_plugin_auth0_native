package asia.ivity.flutter.auth0_native;

import androidx.annotation.Nullable;
import com.auth0.android.result.Credentials;

interface OnCredentialsChangedListener {
  void onCredentialsChanged(@Nullable Credentials credentials);
}
