# Claim ownership
RUN chown -v -R ${username}:${username} /home/${username}

# Claim ownership of /opt. If not sudo is required to make any
# changes to Avery files, including git
RUN chown -v -R ${username}:${username} /opt

