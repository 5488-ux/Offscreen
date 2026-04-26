# Offscreen signing notes

Offscreen must use its own Bundle ID and provisioning profile. Reusing the OpsAI profile causes two issues:

- The installed app conflicts with OpsAI because the signed Bundle ID is the same.
- Screen Time authorization can fail with `Couldn't communicate with a helper application` because the profile does not contain the FamilyControls entitlement for Offscreen.

Required production values:

- Bundle ID: `app.mango7143.offscreen`
- Version: `2.0`
- Team ID: your Apple Developer Team ID
- Capabilities: Family Controls / Screen Time, HealthKit, Notifications

After creating the new profile, update these GitHub secrets:

- `IOS_MOBILEPROVISION_BASE64`
- `IOS_BUNDLE_ID`
- `IOS_PROFILE_NAME`
- `IOS_TEAM_ID`
- `IOS_CERT_PEM_BASE64`
- `IOS_KEY_PEM_BASE64`

