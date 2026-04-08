using './main.bicep'
// parameters
param location string = resourceGroup().location
param vmName string = 'JenkinsServer'
param scriptUrl string = 'https://raw.githubusercontent.com/asadsheikh2025oct/Project-20b-Automated-Jenkins-Deployment/refs/heads/main/install-jenkins.sh'
param adminUsername string = 'azure-user'
@description('The SSH Public Key used to authenticate with the VM.')
param adminSshKey string = getSecret('https://kv20260407.vault.azure.net/', 'jenkins-azure')

