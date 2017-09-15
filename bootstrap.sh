#!/bin/bash

fatalln() {
    echo $*
    exit 1
}

install_plugin() {
    java -jar jenkins-cli.jar -noKeyAuth -s ${url} install-plugin $1 --username admin --password ${password} 2>/dev/null
}

restart_jenkins() {
    java -jar jenkins-cli.jar -noKeyAuth -s ${url} restart --username admin --password ${password} 2>/dev/null
}

#################

[ -z $1 ] && fatalln Instance name needed
instance=$1
plugins=$2

port=8080
while nc -z localhost ${port}; do
    port=$(shuf -i 2000-65000 -n 1)
done

echo "Creating instance \"${instance}\""

mkdir ${instance}

docker pull jenkins
docker run  -d -p ${port}:8080 -v $(pwd)/${instance}:/var/jenkins_home --name ${instance} jenkins

echo "Waiting for \"${instance}\" Jenkins instance to start.."
sleep 20

password=$(cat ${instance}/secrets/initialAdminPassword)
url="http://localhost:${port}"

echo "Getting jenkins cli"
wget -O jenkins-cli.jar ${url}/jnlpJars/jenkins-cli.jar

if [ -f "${plugins}" ]; then
    # Install plugins
    while read -r line; do
        install_plugin ${line} </dev/null
    done < ${plugins}
fi

# No initial setup screen
cp ${instance}/jenkins.install.UpgradeWizard.state ${instance}/jenkins.install.InstallUtil.lastExecVersion
restart_jenkins

rm jenkins-cli.jar

echo "URL: ${url}"
echo "Admin password: ${password}"

# Create env file for other tools
cat >${instance}.env <<EOCFG
user=admin
password=${password}
url=${url}
EOCFG
