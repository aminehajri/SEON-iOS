
This SDK provides the following features:

1. **takePhoto** - Captures a photo and saves it to the device storage.
2. **accessPhoto** - Retrieves the captured photo from storage.
3. **authenticateUser** - Uses the iOS device's built-in biometric authentication to verify the user.

> **Note:** The `.xcframework` liabray is included in `/output` folder of this repository.

## Project Structure

The project is divided into 2 parts:

1. **CameraSDK** - The core SDK providing camera and biometric functionalities.
2. **DemoApp** - A sample application demonstrating how to integrate and use the `CameraSDK` in an iOS app.

### Demo App

The demo app is a simple iOS application that showcases how to use the CameraSDK features:

- Capture and save a photo using `takePhoto`.
- Retrieve and display the app saved photos on the device using `accessPhotos`.
- Authenticate a user using the device's biometrics with `authenticateUser`.
