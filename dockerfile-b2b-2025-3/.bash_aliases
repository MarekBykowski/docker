cat << 'EOF'
Welcome to the Docker b2b 2025-3 container!

  `source /opt/avery/2025-3/avery_qemu_env/enviroment_setup.sh`

  and follow howto
EOF

if [[ : ]]; then
export https_proxy=http://proxy-us.intel.com:912
export HTTPS_PROXY=$https_proxy
export http_proxy=http://proxy-us.intel.com:911
export HTTP_PROXY=$http_proxy
export ftp_proxy=http://proxy-us.intel.com:911
export FTP_PROXY=$ftp_proxy
export socks_proxy=http://proxy-us.intel.com:1080
export SOCKS_PROXY=$socks_proxy
export no_proxy=127.0.0.1
#yocto
export GIT_PROXY_COMMAND="oe-git-proxy"
export NO_PROXY=$no_proxy
fi
