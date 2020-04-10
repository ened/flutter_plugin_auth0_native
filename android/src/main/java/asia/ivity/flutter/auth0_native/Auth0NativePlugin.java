package asia.ivity.flutter.auth0_native;

import android.content.Context;
import android.os.Handler;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.auth0.android.result.Credentials;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** Auth0NativePlugin */
public class Auth0NativePlugin implements FlutterPlugin, ActivityAware {

  private MethodCallHandlerImpl methodCallHandler;
  private MethodChannel channel;

  // Credentials handling
  private EventChannel credentialsEventChannel;
  @Nullable private EventSink credentialsEventSink;
  @Nullable private Credentials latestCredentials;

  private Handler mainThreadHandler;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    startListening(
        flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger());
  }

  public static void registerWith(Registrar registrar) {
    Auth0NativePlugin plugin = new Auth0NativePlugin();

    plugin.startListening(registrar.context(), registrar.messenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    credentialsEventChannel.setStreamHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    methodCallHandler.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    methodCallHandler.setActivity(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    methodCallHandler.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    methodCallHandler.setActivity(null);
  }

  private void startListening(Context applicationContext, BinaryMessenger messenger) {
    mainThreadHandler = new Handler();
    methodCallHandler =
        new MethodCallHandlerImpl(
            applicationContext,
            mainThreadHandler,
            credentials -> {
              latestCredentials = credentials;

              if (credentialsEventSink != null) {
                mainThreadHandler.post(
                    () -> credentialsEventSink.success(Mappers.mapCredentials(latestCredentials)));
              }
            });

    channel = new MethodChannel(messenger, "asia.ivity.flutter/auth0_native/methods");
    channel.setMethodCallHandler(methodCallHandler);

    credentialsEventChannel =
        new EventChannel(messenger, "asia.ivity.flutter/auth0_native/credentials");
    credentialsEventChannel.setStreamHandler(
        new StreamHandler() {
          @Override
          public void onListen(Object arguments, EventSink events) {
            Auth0NativePlugin.this.credentialsEventSink = events;

            mainThreadHandler.post(() -> events.success(Mappers.mapCredentials(latestCredentials)));
          }

          @Override
          public void onCancel(Object arguments) {
            Auth0NativePlugin.this.credentialsEventSink = null;
          }
        });
  }
}
