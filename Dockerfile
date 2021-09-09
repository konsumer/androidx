FROM bitnami/minideb:latest as avd-base

# These are used below to grab stuff
# initial SDK tools version (can be updated later with sdkmanager)
ARG SDK_VERSION="7583922"
ARG MAGISK_VERSION="v23.0"
ENV ANDROID_API="30"
ENV ANDROID_TAG="google_apis_playstore"

ENV ANDROID_SDK_ROOT=/opt/android
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools/:${ANDROID_SDK_ROOT}/emulator:/opt/magisk/bin

# download SDK and magisk binaries from upstream
ADD https://dl.google.com/android/repository/commandlinetools-linux-${SDK_VERSION}_latest.zip /tmp/android-sdk.zip
ADD https://github.com/topjohnwu/Magisk/releases/download/${MAGISK_VERSION}/Magisk-${MAGISK_VERSION}.apk /opt/magisk/magisk.apk

# install system-deps
RUN install_packages default-jre squashfs-tools binutils cpio unzip libxcb-xinerama0 libxi6 libxtst6 libpulse0 libglu1-mesa libnss3 libxcomposite1 libxcursor1 libasound2
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && unzip /tmp/android-sdk.zip -d /tmp > /dev/null && mv /tmp/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest
RUN yes | sdkmanager --licenses > /dev/null && sdkmanager "emulator" "platform-tools"


# setup magisk
ADD magiskpatch /opt/magisk/bin/magiskpatch
RUN cd /tmp && unzip /opt/magisk/magisk.apk > /dev/null && \
  mv lib/x86/libmagiskinit.so /opt/magisk/bin/magiskinit && \
  mv lib/x86/libmagiskboot.so /opt/magisk/bin/magiskboot && \
  chmod +x /opt/magisk/bin/* && \
  magiskboot compress=xz lib/x86/libmagisk64.so /opt/magisk/bin/magisk64.xz && \
  magiskboot compress=xz lib/x86/libmagisk32.so /opt/magisk/bin/magisk32.xz

# add emulator entry-point
ADD run_emulator ${ANDROID_SDK_ROOT}/platform-tools/run_emulator

# cleanup
RUN rm -rf /tmp/*

FROM avd-base as emulator
ENV QT_X11_NO_MITSHM=1
CMD run_emulator
