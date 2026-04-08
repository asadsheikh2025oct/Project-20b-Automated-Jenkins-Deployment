using './main.bicep'
// parameters
param location = resourceGroup().location
param vmName = 'JenkinsServer'
param scriptUrl = 'https://raw.githubusercontent.com/asadsheikh2025oct/Project-20b-Automated-Jenkins-Deployment/refs/heads/main/install-jenkins.sh'
param adminUsername = 'azure-user'
@description('The SSH Public Key used to authenticate with the VM.')
param adminSshKey = getSecret('https://kv20260407.vault.azure.net/', 'jenkins-azure')

