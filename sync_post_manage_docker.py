import docker
import os
import shutil


def register():
    return "/var/lib/cobbler/triggers/sync/post/*"


def run(api, args, logger):
    shutil.copyfile("/etc/dnsmasq.conf", "/etc/cobbler/dnsmasq.conf")

    try:
        client = docker.from_env()
        container = os.environ["COBBLER_MANAGED_CONTAINER"]
        if container:
            containers = [client.containers.get(container)]
        else:
            containers = client.containers.list(filters={"label": "io.github.cobbler.service.dnsmasq"})
        for container in containers:
            container.restart()
    except:
        logger.error("restarting docker container failed")
        return 1
    return 0
