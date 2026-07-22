package com.shirsh94.smsotpautofill;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.telephony.TelephonyManager;
import android.util.Log;

import androidx.activity.result.IntentSenderRequest;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.content.ContextCompat;

import com.google.android.gms.auth.api.identity.GetPhoneNumberHintIntentRequest;
import com.google.android.gms.auth.api.identity.Identity;
import com.google.android.gms.auth.api.phone.SmsRetriever;
import com.google.android.gms.auth.api.phone.SmsRetrieverClient;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * SmsOtpAutoFillPlugin
 */
public class SmsOtpAutoFillPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {

    private static final int PHONE_HINT_REQUEST = 11012;
    private static final int SMS_CONSENT_REQUEST = 11013;
    private static final String channelName = "sms_autofill_plus";
    private static final String NOTIFICATION_CHANNEL_ID = "sms_otp_mock_channel";

    private Activity activity;
    private Result pendingHintResult;
    private MethodChannel channel;
    private SmsBroadcastReceiver broadcastReceiver;
    private String currentSmsCodeRegexPattern = "(?i)(?:code|otp|verification|is|passcode|pin|v-)[ :\\\\t-]*(\\\\d{4,8})|(?<!\\\\d)(\\\\d{4,8})(?!\\\\d)";

    private final PluginRegistry.ActivityResultListener activityResultListener = new PluginRegistry.ActivityResultListener() {

        @Override
        public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
            try {
                if (requestCode == SmsOtpAutoFillPlugin.PHONE_HINT_REQUEST && pendingHintResult != null) {
                    if (resultCode == Activity.RESULT_OK && data != null) {
                        String phoneNumber =
                                Identity.getSignInClient(activity).getPhoneNumberFromIntent(data);
                        pendingHintResult.success(phoneNumber);
                    } else if (resultCode == Activity.RESULT_CANCELED) {
                        pendingHintResult.success(null);
                    } else {
                        channel.invokeMethod("error", "PERMISSION_DENIED");
                        pendingHintResult.success(null);
                    }
                    return true;
                } else if (requestCode == SMS_CONSENT_REQUEST) {
                    if (resultCode == Activity.RESULT_OK && data != null) {
                        String message = data.getStringExtra(SmsRetriever.EXTRA_SMS_MESSAGE);
                        handleSms(message);
                    } else {
                        channel.invokeMethod("error", "PERMISSION_DENIED");
                    }
                    return true;
                }
            } catch (Exception e) {
                Log.e("Exception", e.toString());
                channel.invokeMethod("error", "UNKNOWN");
            }
            return false;
        }
    };

    public SmsOtpAutoFillPlugin() {
    }

    public void handleSms(String message) {
        if (message != null) {
            Pattern pattern = Pattern.compile(currentSmsCodeRegexPattern, Pattern.CASE_INSENSITIVE);
            Matcher matcher = pattern.matcher(message);

            if (matcher.find()) {
                String code = null;
                for (int i = 1; i <= matcher.groupCount(); i++) {
                    if (matcher.group(i) != null) {
                        code = matcher.group(i);
                        break;
                    }
                }
                
                if (code == null) {
                    code = matcher.group(0);
                }
                
                channel.invokeMethod("smscode", code);
            } else {
                channel.invokeMethod("smscode", message);
            }
        }
    }

    public void onTimeout() {
        channel.invokeMethod("timeout", null);
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull final Result result) {
        switch (call.method) {
            case "requestPhoneHint":
                pendingHintResult = result;
                requestHint();
                break;
            case "listenForCode":
                if (!checkPlayServices()) {
                    channel.invokeMethod("error", "PLAY_SERVICES_MISSING");
                    result.success(null);
                    return;
                }

                String regex = call.argument("smsCodeRegexPattern");
                if (regex != null) {
                    currentSmsCodeRegexPattern = regex;
                }
                
                String strategy = call.argument("strategy");
                String senderPhoneNumber = call.argument("senderPhoneNumber");

                SmsRetrieverClient client = SmsRetriever.getClient(activity);
                
                if ("retriever".equals(strategy) || "auto".equals(strategy)) {
                    client.startSmsRetriever();
                }

                if ("consent".equals(strategy) || "auto".equals(strategy)) {
                    client.startSmsUserConsent(senderPhoneNumber);
                }

                unregisterReceiver();// unregister existing receiver
                broadcastReceiver = new SmsBroadcastReceiver(new WeakReference<>(SmsOtpAutoFillPlugin.this));
                
                IntentFilter intentFilter = new IntentFilter(SmsRetriever.SMS_RETRIEVED_ACTION);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    activity.registerReceiver(broadcastReceiver, intentFilter, Context.RECEIVER_EXPORTED);
                } else {
                    activity.registerReceiver(broadcastReceiver, intentFilter);
                }
                result.success(null);
                break;
            case "getDiagnostics":
                Map<String, Object> diagnostics = new HashMap<>();
                diagnostics.put("isPlayServicesAvailable", checkPlayServices());
                diagnostics.put("isRetrieverAvailable", true); // We assume true if Play Services is OK
                diagnostics.put("isUserConsentAvailable", Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT);
                diagnostics.put("appSignature", new AppSignatureHelper(activity).getAppSignature());
                diagnostics.put("isReceiverRegistered", broadcastReceiver != null);
                result.success(diagnostics);
                break;
            case "unregisterListener":
                unregisterReceiver();
                result.success("successfully unregister receiver");
                break;
            case "getAppSignature":
                AppSignatureHelper signatureHelper = new AppSignatureHelper(activity.getApplicationContext());
                String appSignature = signatureHelper.getAppSignature();
                result.success(appSignature);
                break;
            case "simulateMessage":
                String message = call.argument("message");
                showMockNotification(message);
                handleSms(message);
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private boolean checkPlayServices() {
        GoogleApiAvailability apiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = apiAvailability.isGooglePlayServicesAvailable(activity);
        return resultCode == ConnectionResult.SUCCESS;
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    private void requestHint() {

        if (!isSimSupport()) {
            channel.invokeMethod("error", "UNSUPPORTED_DEVICE");
            if (pendingHintResult != null) {
                pendingHintResult.success(null);
            }
            return;
        }

        GetPhoneNumberHintIntentRequest request =
                GetPhoneNumberHintIntentRequest.builder().build();

        Identity.getSignInClient(activity)
                .getPhoneNumberHintIntent(request)
                .addOnSuccessListener(new OnSuccessListener<PendingIntent>() {
                    @Override
                    public void onSuccess(PendingIntent pendingIntent) {
                        try {
                            IntentSenderRequest intentSenderRequest = new IntentSenderRequest.Builder(pendingIntent).build();
                            activity.startIntentSenderForResult(
                                    intentSenderRequest.getIntentSender(),
                                    SmsOtpAutoFillPlugin.PHONE_HINT_REQUEST, null, 0, 0, 0
                            );
                        } catch (Exception e) {
                            e.printStackTrace();
                            channel.invokeMethod("error", "UNKNOWN");
                            pendingHintResult.error("ERROR", e.getMessage(), e);
                        }
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(Exception e) {
                        e.printStackTrace();
                        channel.invokeMethod("error", "PLAY_SERVICES_MISSING");
                        pendingHintResult.error("ERROR", e.getMessage(), e);
                    }
                });
    }

    public boolean isSimSupport() {
        TelephonyManager telephonyManager = (TelephonyManager) activity.getSystemService(Context.TELEPHONY_SERVICE);
        return !(telephonyManager.getSimState() == TelephonyManager.SIM_STATE_ABSENT);
    }

    private void setupChannel(BinaryMessenger messenger) {
        channel = new MethodChannel(messenger, SmsOtpAutoFillPlugin.channelName);
        channel.setMethodCallHandler(this);
    }

    private void unregisterReceiver() {
        if (broadcastReceiver != null) {
            try {
                activity.unregisterReceiver(broadcastReceiver);
            } catch (Exception ex) {
                // silent catch to avoir crash if receiver is not registered
            }
            broadcastReceiver = null;
        }
    }

    private void showMockNotification(String message) {
        if (activity == null) {
            Log.e("SmsOtpAutoFill", "Could not show notification: activity is null");
            return;
        }

        Log.d("SmsOtpAutoFill", "Showing mock notification: " + message);

        Context context = activity.getApplicationContext();
        
        if (Build.VERSION.SDK_INT >= 33) {
            if (ContextCompat.checkSelfPermission(context, "android.permission.POST_NOTIFICATIONS") != PackageManager.PERMISSION_GRANTED) {
                Log.w("SmsOtpAutoFill", "POST_NOTIFICATIONS permission not granted. Requesting...");
                ActivityCompat.requestPermissions(activity, new String[]{"android.permission.POST_NOTIFICATIONS"}, 11014);
            }
        }

        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    NOTIFICATION_CHANNEL_ID,
                    "Mock SMS OTP",
                    NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription("Notifications for mock SMS messages during testing");
            notificationManager.createNotificationChannel(channel);
        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
                .setSmallIcon(android.R.drawable.stat_notify_chat)
                .setContentTitle("Mock SMS Received")
                .setContentText(message)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true);

        notificationManager.notify((int) System.currentTimeMillis(), builder.build());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        setupChannel(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        unregisterReceiver();
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addActivityResultListener(activityResultListener);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        unregisterReceiver();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addActivityResultListener(activityResultListener);
    }

    @Override
    public void onDetachedFromActivity() {
        unregisterReceiver();
    }

    private static class SmsBroadcastReceiver extends BroadcastReceiver {

        final WeakReference<SmsOtpAutoFillPlugin> plugin;

        private SmsBroadcastReceiver(WeakReference<SmsOtpAutoFillPlugin> plugin) {
            this.plugin = plugin;
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            if (SmsRetriever.SMS_RETRIEVED_ACTION.equals(intent.getAction())) {
                if (plugin.get() == null) {
                    return;
                }

                Bundle extras = intent.getExtras();
                Status status;
                if (extras != null) {
                    status = (Status) extras.get(SmsRetriever.EXTRA_STATUS);
                    if (status != null) {
                        switch (status.getStatusCode()) {
                            case CommonStatusCodes.SUCCESS:
                                Intent consentIntent = extras.getParcelable(SmsRetriever.EXTRA_CONSENT_INTENT);
                                if (consentIntent != null) {
                                    // User Consent API: show prompt
                                    plugin.get().activity.startActivityForResult(consentIntent, SMS_CONSENT_REQUEST);
                                } else {
                                    // Retriever API: get message immediately
                                    String message = (String) extras.get(SmsRetriever.EXTRA_SMS_MESSAGE);
                                    plugin.get().handleSms(message);
                                    plugin.get().unregisterReceiver();
                                }
                                break;
                            case CommonStatusCodes.TIMEOUT:
                                plugin.get().onTimeout();
                                plugin.get().unregisterReceiver();
                                break;
                        }
                    }
                }
            }
        }
    }
}
