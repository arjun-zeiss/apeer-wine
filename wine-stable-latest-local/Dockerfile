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

# Install Winetricks
RUN apt-get install -y cabextract
COPY winetricks .
RUN chmod +x winetricks
RUN cp winetricks /usr/local/bin

# Set Wine architecture to 64-bit
ENV WINEARCH win64
# Set the Wine prefix (place where Wine environment will be installed)
ENV WINEPREFIX /opt/wineprefix
# Turn off fixme messages from Wine
ENV WINEDEBUG fixme-all

# Install .NET Framework 4.7.2
RUN wineboot \
 && winetricks -q --force dotnet472

# Install Visual C++ Redistributable 2010
RUN wineboot -u && xvfb-run winetricks -q vcrun2010

# Install Python
ENV PYVER 3.7.9
ENV PYARCH amd64

RUN umask 0
WORKDIR /tmp/helper

COPY python-${PYVER}-${PYARCH}.exe .
RUN xvfb-run sh -c "\
  wine64 python-${PYVER}-${PYARCH}.exe /quiet TargetDir=C:\\Python37-64 \
    Include_doc=0 InstallAllUsers=1 PrependPath=1; \
  wineserver -w"

# Cleanup
RUN rm -Rf /tmp/helper

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

# Unneccessary? Copy DLL dependencies to system32 and syswow64 directories
COPY system32/*.dll ${WINEPREFIX}/drive_c/windows/system32/
COPY syswow64/*.dll ${WINEPREFIX}/drive_c/windows/syswow64/

# Unneccessary? Reboot Wine
RUN wineboot -u

# Add the APEER app directory to the Wine environment path
ENV WINEPATH Z:\\usr\\src\\app
RUN wine64 cmd
