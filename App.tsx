import React, {FC, useEffect, useState} from 'react';
import {Text, StyleSheet} from 'react-native';
import {
  Camera,
  CameraPermissionStatus,
  useCameraDevices,
} from 'react-native-vision-camera';

const App: FC = () => {
  const [cameraPermissionStatus, setCameraPermissionStatus] =
    useState<CameraPermissionStatus>('not-determined');
  const devices = useCameraDevices('wide-angle-camera');
  const device = devices.back;

  useEffect(() => {
    Camera.getCameraPermissionStatus().then(setCameraPermissionStatus);
  }, []);

  if (device == null) {
    return <Text>No device</Text>;
  }

  if (cameraPermissionStatus !== 'authorized') {
    return (
      <Text>Invalid camera permission status {cameraPermissionStatus}</Text>
    );
  }

  return (
    <Camera style={StyleSheet.absoluteFill} device={device} isActive={true} />
  );
};

export default App;
