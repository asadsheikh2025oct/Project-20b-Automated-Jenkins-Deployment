using './main.bicep'
param vmName = 'JenkinsServer'
param scriptUrl = 'https://raw.githubusercontent.com/asadsheikh2025oct/Project-20b-Automated-Jenkins-Deployment/refs/heads/main/install-jenkins.sh'
param adminUsername = 'azure-user'
param adminSshKey = getSecret('f2f1d6df-9422-48cb-abf1-0a4eb095ad4a','project20b','kv20260407', 'jenkins-azure')