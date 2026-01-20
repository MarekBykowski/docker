# User  env & UX
# terminal
COPY config/xfce4/terminal/terminalrc /home/${username}/.config/xfce4/terminal/terminalrc
# wallpaper
COPY config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml /home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
# icon theme
COPY config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml /home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# add my sys config files
COPY etc /etc
