# This Dockerfile is based on Debian Buster
#
# Versions:
#   Wine Latest Stable
#   Winetricks (latest)
#   .NET 4.7.2
#   Visual C++ 2010
#   Python 3.7.9
#   PythonNet 2.5.1
#
# The container gets the following error when attempting to run:
# System.IO.FileNotFoundException: Could not load file or assembly 'CZM.Common.Algorithms, Version=1.0.7293.23757, Culture=neutral, PublicKeyToken=null' or one of its dependencies. File not found.
#   at Czm.Oct.Analysis.Core.OctAnalysisEngine..cctor()
#
# The above exception was the direct cause of the following exception:
#
# Traceback (most recent call last):
#  File "mta.py", line 124, in <module>
#    print(execute('Diverse', 1024, 512, 128, 254, 62, False, 'ilmDataArray', 'rpeDataArray'))
#  File "mta.py", line 62, in execute
#    output = calculate_etdrs_wrapper.CalculateEtdrs(population_types[population.lower()], aScanLength, bScanWidth, numberOfSlices, foveaCenterX, foveaCenterY, isOd, ilmDataKey, rpeDataKey, params_file)
# System.TypeInitializationException: The type initializer for 'Czm.Oct.Analysis.Core.OctAnalysisEngine' threw an exception.
#    at Czm.Oct.Analysis.Core.OctAnalysisEngine..ctor()
#    at Czm.Oct.Analysis.Workflow.PythonNet.Wrapper.CalculateEtdrsWrapper.CalculateEtdrs(Int32 population, Int32 aScanLength, Int32 bScanWidth, Int32 numberOfSlices, Int32 foveaCenterX, Int32 foveaCenterY, Boolean isOd, String ilmDataKey, String rpeDataKey, String parametersFile)

#FROM debian:buster
FROM amd64/debian:buster

# Install wget
RUN apt-get update
RUN apt-get install -y wget

# Need wine 1.7.xx for this all to work, so we'll use the PPA:
#RUN dpkg --add-architecture i386 \
# && echo "deb http://ppa.launchpad.net/ubuntu-wine/ppa/ubuntu trusty main" >> /etc/apt/sources.list.d/wine.list \
# && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5A9A06AEF9CB8DB0 \
# && apt-get update \
# && apt-get install --no-install-recommends -qfy wine5.0.3 winetricks \
# && apt-get clean

RUN apt-get update
RUN apt-get -y install gnupg2 software-properties-common
RUN wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add -

RUN apt-add-repository https://dl.winehq.org/wine-builds/debian/

RUN dpkg --add-architecture i386

RUN apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		unzip \
		xauth \
		xvfb

RUN wget -O- -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key | apt-key add -    
RUN echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" | tee /etc/apt/sources.list.d/wine-obs.list
 
# Install Wine
RUN apt-get update
RUN apt-get install -y --install-recommends winehq-stable
#RUN apt-get install -y --install-recommends wine-stable=5.0.0~buster_i386
RUN apt-get install -y --install-recommends winbind

# Install Winetricks
RUN apt-get install -y cabextract
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN chmod +x winetricks
RUN cp winetricks /usr/local/bin

#RUN apt-get update -y && \
#	apt-get install -y --no-install-recommends winehq-stable

ENV WINEDEBUG -all
#ENV WINEARCH win32
ENV WINEARCH win64
ENV WINEPREFIX /opt/wineprefix
#ENV WINEPREFIX /root/.wine
# Silence all the "fixme: blah blah blah" messages from wine
ENV WINEDEBUG fixme-all

COPY wine-init.sh SHA256SUMS.txt /tmp/helper/
COPY mkuserwineprefix /opt/

# Install Wine Mono
#RUN wget -P /mono http://dl.winehq.org/wine/wine-mono/5.1.0/wine-mono-5.1.0-x86.msi
#RUN wineboot -u && msiexec /i /mono/wine-mono-5.1.0-x86.msi
#RUN rm -rf /mono/wine-mono-5.1.0-x86.msi

# Prepare environment
#RUN xvfb-run sh /tmp/helper/wine-init.sh

#RUN useradd -d /app -m app
#USER app
#ENV HOME /app
#RUN mkdir -p /app/src
#RUN mkdir -p /app/.profile.d
#WORKDIR /app/src

# Install the .net 4.0 runtime (not actually required for python!)
#RUN wineboot \
#&& winetricks -q dotnet40 \
#&& while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
#&& rm -rf $HOME/.cache/winetricks

#RUN wineboot \
#&& winetricks -q dotnet40
RUN wineboot \
 && winetricks -q --force dotnet472

# Install Visual C++ Redistributable 
RUN wineboot -u && xvfb-run winetricks -q vcrun2010

# Install Python
ENV PYVER 3.7.9
ENV PYARCH amd64

RUN umask 0 && cd /tmp/helper && \
  curl -LOO \
    https://www.python.org/ftp/python/${PYVER}/python-${PYVER}-${PYARCH}.exe \
    https://github.com/upx/upx/releases/download/v3.96/upx-3.96-win32.zip \
  && \
  #sha256sum -c SHA256SUMS.txt && \
  xvfb-run sh -c "\
    wine64 python-${PYVER}-${PYARCH}.exe /quiet TargetDir=C:\\Python37-64 \
    #wine64 python-${PYVER}-${PYARCH}.exe /quiet TargetDir=C:\\Python37-32 \
      Include_doc=0 InstallAllUsers=1 PrependPath=1; \
    wineserver -w" && \
  unzip upx*.zip && \
  mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/ && \
  cd .. && rm -Rf helper

#ENV WINEDEBUG warn+all

#RUN Xvfb :42 -screen 10 1024x768x8 &

#RUN umask 0 && cd /tmp/helper && curl -LOO https://www.python.org/ftp/python/${PYVER}/python-${PYVER}.exe
#RUN cd /tmp/helper && DISPLAY=:42 wine64 python-${PYVER}.exe /quiet TargetDir=C:\\Python37-64 Include_doc=0 InstallAllUsers=1 PrependPath=1; \
#    wineserver -w
#RUN rm -rf /tmp/helper

# PythonNet dependencies
RUN apt-get install -y clang
RUN apt-get install -y libglib2.0-dev
RUN apt-get install -y python-dev

ENV PATH ${HOME}/bin:${PATH}

RUN wine64 pip install pycparser \
  && wine64 pip install pythonnet==2.5.1

WORKDIR /usr/src/app
COPY requirements.txt .
RUN wine64 pip install -r requirements.txt; wineserver -w
COPY apeer_dev_kit ./apeer_dev_kit
ADD lib .
#COPY *.dll .
COPY mta.py .
COPY apeer_main.py .
COPY parameters.xml .
COPY ilmDataArray.bin .
COPY rpeDataArray.bin .
COPY module_specification.json .

COPY init-fusion.sh .
RUN chmod +x init-fusion.sh

#COPY system32/ .
#WORKDIR /usr/src/app/system32
COPY system32/*.dll /opt/wineprefix/drive_c/windows/system32/
COPY syswow64/*.dll /opt/wineprefix/drive_c/windows/syswow64/

WORKDIR /usr/src/app

# Enable Fusion Logging
#RUN wine64 reg add "HKLM\\SOFTWARE\\Microsoft\\Fusion" /v ForceLog /t REG_DWORD /d 1 /f
#RUN wine64 reg add "HKLM\\SOFTWARE\\Microsoft\\Fusion" /v LogFailures /t REG_DWORD /d 1 /f
#RUN wine64 reg add "HKLM\\SOFTWARE\\Microsoft\\Fusion" /v LogResourceBinds /t REG_DWORD /d 1 /f
#RUN wine64 reg add "HKLM\\SOFTWARE\\Microsoft\\Fusion" /v EnableLog /t REG_DWORD /d 1 /f
#RUN mkdir /opt/wineprefix/drive_c/FusionLog
#RUN wine64 reg add "HKLM\\SOFTWARE\\Microsoft\\Fusion" /v EnableLog /t REG_SZ /d "C:\\FusionLog\\" /f

RUN wineboot -u

ENV WINEPATH Z:\\usr\\src\\app
RUN wine64 cmd

ENTRYPOINT [ "wine64", "python", "./apeer_main.py" ]