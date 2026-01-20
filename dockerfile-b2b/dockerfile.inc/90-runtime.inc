# ports
EXPOSE 22 5900 6080

# default command
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
