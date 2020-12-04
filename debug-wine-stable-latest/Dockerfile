# This Dockerfile is based on Debian Buster
#
# Versions:
#   Wine Stable (latest)
#   Winetricks (latest)
#   .NET 4.7.2
#   Visual C++ 2010
#   Python 3.7.9
#   PythonNet 2.5.1
#

FROM amd64/debian:buster

# Update package lists
RUN apt-get update

# Install wget
RUN apt-get install -y wget

# Install software properties and gnupg2 so we can add wine repository
RUN apt-get -y install gnupg2 software-properties-common

# Install other needed packages
RUN apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		unzip \
		xauth \
		xvfb

# Get the Wine repository public key
RUN wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add -

# Add the Wine repository
RUN apt-add-repository https://dl.winehq.org/wine-builds/debian/

# Add i386 (32-bit) architecture as valid so Wine can be installed
RUN dpkg --add-architecture i386

# Unneccessary?  Add Debian 10 Wine repo
RUN wget -O- -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key | apt-key add -    
RUN echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" | tee /etc/apt/sources.list.d/wine-obs.list
 
# Install Wine (latest stable) and winbind
RUN apt-get update
RUN apt-get install -y --install-recommends winehq-stable
RUN apt-get install -y --install-recommends winbind

# Install Winetricks (latest script from GitHub repo)
RUN apt-get install -y cabextract
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN chmod +x winetricks
RUN cp winetricks /usr/local/bin

# Set Wine architecture to 64-bit
ENV WINEARCH win64
# Set the Wine prefix (place where Wine environment will be installed)
ENV WINEPREFIX /opt/wineprefix
# Turn off fixme messages from Wine
ENV WINEDEBUG fixme-all

# Unneccessary? Copy scripts to initialize Wine environment and sha256 checksums
# IF YOU REMOVE THIS, MAKE SURE YOU ADD MKDIR /tmp/helper/!
COPY wine-init.sh SHA256SUMS.txt /tmp/helper/
COPY mkuserwineprefix /opt/

# Install .NET Framework 4.7.2
RUN wineboot \
 && winetricks -q --force dotnet472

# Install Visual C++ Redistributable 2010
RUN wineboot -u && xvfb-run winetricks -q vcrun2010

# Install Python (64-bit)
ENV PYVER 3.7.9
# NOTE: Changing PYARCH to x86 or similar to install 32-bit Python will not work!
# 32-bit Python installers are at:
# https://www.python.org/ftp/python/${PYVER}/python-${PYVER}.exe
ENV PYARCH amd64

RUN umask 0 && cd /tmp/helper && \
  curl -LOO \
    https://www.python.org/ftp/python/${PYVER}/python-${PYVER}-${PYARCH}.exe \
    https://github.com/upx/upx/releases/download/v3.96/upx-3.96-win32.zip \
  && \
  xvfb-run sh -c "\
    wine64 python-${PYVER}-${PYARCH}.exe /quiet TargetDir=C:\\Python37-64 \
      Include_doc=0 InstallAllUsers=1 PrependPath=1; \
    wineserver -w" && \
  unzip upx*.zip && \
  mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/ && \
  cd .. && rm -Rf helper

# Install pythonnet dependency packages
RUN apt-get install -y clang
RUN apt-get install -y libglib2.0-dev
RUN apt-get install -y python-dev

# Unneccessary? Add home bin directory to path
ENV PATH ${HOME}/bin:${PATH}

# Install pycparser and pythonnet
RUN wine64 pip install pycparser \
  && wine64 pip install pythonnet==2.5.1

WORKDIR /usr/src/app

# Copy custom APEER Dev Kit Python library made to work with Wine
COPY apeer_dev_kit ./apeer_dev_kit

# Copy the script to enable fusion logging
COPY init-fusion.sh .
RUN chmod +x init-fusion.sh

# Unneccessary? Copy DLL dependencies to system32 and syswow64 directories
COPY system32/*.dll ${WINEPREFIX}/drive_c/windows/system32/
COPY syswow64/*.dll ${WINEPREFIX}/drive_c/windows/syswow64/

# Unneccessary? Reboot Wine
RUN wineboot -u

# Add the APEER app directory to the Wine environment path
ENV WINEPATH Z:\\usr\\src\\app
RUN wine64 cmd
