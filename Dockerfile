FROM openjdk:slim as avd-base

# These are used below to grab stuff
# initial SDK tools version (can be updated later with sdkmanager)
ARG SDK_VERSION="7583922"
ARG MAGISK_VERSION="v23.0"
ARG ANDROID_API="30"
ARG ANDROID_TAG="google_apis_playstore"

ENV ANDROID_SDK_ROOT=/opt/android
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools/:${ANDROID_SDK_ROOT}/emulator:/opt/magisk/bin

# download SDK and magisk binaries from upstream
ADD https://dl.google.com/android/repository/commandlinetools-linux-${SDK_VERSION}_latest.zip /tmp/android-sdk.zip
ADD https://github.com/topjohnwu/Magisk/releases/download/${MAGISK_VERSION}/Magisk-${MAGISK_VERSION}.apk /opt/magisk/magisk.apk

# install system-deps
RUN apt-get update && apt-get install -y tree binutils cpio unzip libxcb-xinerama0 libxi6 libxtst6 libpulse0 libglu1-mesa libnss3 libxcomposite1 libxcursor1 libasound2

RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && unzip /tmp/android-sdk.zip -d /tmp > /dev/null && mv /tmp/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest
RUN yes | sdkmanager --licenses > /dev/null && sdkmanager "system-images;android-${ANDROID_API};${ANDROID_TAG};x86_64" "platform-tools" "platforms;android-${ANDROID_API}"

# setup emulator
RUN echo no | avdmanager create avd --force --name "default" \
  --abi ${ANDROID_TAG}/x86_64 \
  --package "system-images;android-${ANDROID_API};${ANDROID_TAG};x86_64"


# setup magisk
ADD magiskpatch /opt/magisk/bin/magiskpatch
RUN cd /tmp && unzip /opt/magisk/magisk.apk > /dev/null && \
  mv lib/x86/libmagiskinit.so /opt/magisk/bin/magiskinit && \
  mv lib/x86/libmagiskboot.so /opt/magisk/bin/magiskboot && \
  chmod +x /opt/magisk/bin/* && \
  magiskboot compress=xz lib/x86/libmagisk64.so /opt/magisk/bin/magisk64.xz && \
  magiskboot compress=xz lib/x86/libmagisk32.so /opt/magisk/bin/magisk32.xz

# patch ramdisk for root/magisk
RUN magiskpatch ${ANDROID_SDK_ROOT}/system-images/android-${ANDROID_API}/${ANDROID_TAG}/x86_64/ramdisk.img

# cleanup
RUN rm -rf /tmp/* /var/lib/apt/lists/*

FROM avd-base as emulator

ENV QT_X11_NO_MITSHM=1

CMD [ "emulator", "@default"]