// parameters
param location string
param vmName string = 
param adminUsername string = 
param scriptUrl string
@description('The SSH Public Key used to authenticate with the VM.')
@secure()
param adminSshKey string


// Vnet Subnet IP
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: '${vmName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: '${vmName}-subnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: '${vmName}-publicIP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// nsg
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: '${vmName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-${vmName}-8080'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 1000
          protocol: 'Tcp'
          description: 'Allow inbound traffic into ${vmName}'
          destinationAddressPrefix: '*'
          destinationPortRange: '8080'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
        }
      }
      {
        name: 'AllowSSH'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 900
          protocol: 'Tcp'
          description: 'Allow SSH access to port 22'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      // Optional: Add this later if using JNLP agents (inbound TCP)
      // {
      //   name: 'Allow-JNLP'
      //   properties: {
      //     access: 'Allow'
      //     direction: 'Inbound'
      //     priority: 1010
      //     protocol: 'Tcp'
      //     destinationAddressPrefix: '*'
      //     destinationPortRange: '50000'
      //     sourcePortRange: '*'
      //     sourceAddressPrefix: '*'
      //   }
      // }
    ]
  }
}

// nic
resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    networkSecurityGroup: {
      id: nsg.id
    }
    ipConfigurations: [
      {
        name: '${vmName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

// vm
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'  // Consider upgrading to B2s or higher for better performance
    }
    osProfile: {
      adminUsername: adminUsername
      computerName: vmName
      allowExtensionOperations: true
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminSshKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        offer: '0001-com-ubuntu-server-jammy'
        publisher: 'Canonical'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// vm extension to install jenkins
resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  name: '${vmName}-extension'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'                  // Fix: was 'CustomeScript' (typo)
    typeHandlerVersion: '2.1'             // Fix: was missing (caused the deployment error)
    autoUpgradeMinorVersion: true         // Fix: best practice, was missing
    settings: {
      fileUris: [
        scriptUrl
      ]
      commandToExecute: 'bash install-jenkins.sh'
    }
  }
}
