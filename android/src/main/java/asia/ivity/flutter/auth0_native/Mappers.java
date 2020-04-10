package asia.ivity.flutter.auth0_native;

import androidx.annotation.Nullable;
import com.auth0.android.result.Credentials;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

class Mappers {
  static @Nullable Map<String, Object> mapCredentials(@Nullable Credentials credentials) {
    if (credentials == null) {
      return null;
    }

    HashMap<String, Object> res = new HashMap<>();

    res.put("accessToken", credentials.getAccessToken());
    res.put("idToken", credentials.getIdToken());
    res.put("refreshToken", credentials.getRefreshToken());
    res.put("scope", credentials.getScope());
    res.put("type", credentials.getType());
    Date expiresAt = credentials.getExpiresAt();
    if (expiresAt != null) {
      res.put("expiresAt", expiresAt.getTime());
    } else {
      res.put("expiresAt", null);
    }
    res.put("expiresIn", credentials.getExpiresIn());

    return res;
  }
}
