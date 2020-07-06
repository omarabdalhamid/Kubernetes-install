#!/usr/bin/env sh
# Docker Load oofline Images into local docker registry

sudo docker load <  ./offline/proxy.tar
sudo docker load <  ./offline/ui.tar
sudo docker load <  ./offline/web.tar
sudo docker load <  ./offline/db.tar
sudo docker load <  ./offline/meta.tar
sudo docker load <  ./offline/cron.tar
sudo docker load <  ./offline/worker.tar
