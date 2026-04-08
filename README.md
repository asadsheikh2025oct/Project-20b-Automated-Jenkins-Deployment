### 🚀 Automated Jenkins Deployment (Azure & Bicep)

This project demonstrates an enterprise-grade, "Zero-Touch" deployment of a Jenkins server on an Azure Virtual Machine. By leveraging **Azure Bicep**, **Key Vault**, and **Azure Pipelines**, we ensure that infrastructure is treated as code and sensitive secrets are never hardcoded or exposed in the repository.

---

### 🏗️ Tech Stack
* **IaC:** Azure Bicep + `.bicepparam` (separating logic from environment data).
* **Secrets Management:** Azure Key Vault (securely housing the SSH Public Key).
* **CI/CD:** Azure Pipelines (orchestrating the deployment from GitHub).
* **Configuration:** VM Custom Script Extension (executing the Jenkins installation bash script).

---

### 🔒 Security Architecture: The "Key Card & Registry"
This project implements a high-security handshake between Azure services:
* **The Safe (Key Vault):** Instead of leaving SSH keys in the code, they are stored in a high-security vault.
* **The Order Form (.bicepparam):** A specific configuration form for the environment that tells Azure where to find the "keys" using the `getSecret()` function.
* **The Handshake:** Azure Resource Manager is authorized to "reach in" and grab the secret only during the deployment process.

---

### 📂 Repository Structure
* `infra/main.bicep`: The core logic and blueprint for the Azure resources.
* `infra/main.bicepparam`: The environment configuration and link to Key Vault.
* `scripts/install-jenkins.sh`: The configuration script that installs Java and Jenkins.
* `azure-pipelines.yml`: The automation pipeline that triggers on code changes.

---

### 🛠️ Challenges & Troubleshooting (Lessons Learned)

During the implementation, several real-world hurdles were resolved to achieve a successful deployment:

#### 1. Bicep Parameter Syntax Errors (BCP018 & BCP009)
* **Issue:** The pipeline failed with "Expected the '=' character" and "Expected a literal value" errors.
* **Root Cause:** The `.bicepparam` file contained decorators (like `@description`), type declarations, or comments that interfered with the strict parameter assignment syntax.
* **Solution:** Refactored the `.bicepparam` file to strictly include the `using` statement and clean `param = value` assignments, removing all decorators and complex logic.

#### 2. Key Vault Access Forbidden (KeyVaultParameterReferenceSecretRetrieveFailed)
* **Issue:** The deployment engine could not retrieve the secret from the Key Vault, resulting in a `Forbidden` error.
* **Root Cause:** The Key Vault security wall was blocking Azure Resource Manager from accessing the secrets, and the Network ACLs were not configured to allow bypass for trusted services.
* **Solution:** Enabled **Azure Resource Manager for template deployment** and updated the vault to allow **AzureServices** to bypass the firewall via the Azure CLI.

#### 3. RBAC Permission Handshake
* **Issue:** Even after enabling template deployment, the pipeline lacked permission to read the specific secret.
* **Root Cause:** The vault was using **Azure Role-Based Access Control (RBAC)**, which requires explicit role assignments.
* **Solution:** Assigned the **Key Vault Secrets User** role to the Pipeline's Service Principal, granting the "Least Privilege" necessary for the deployment to succeed.

---

### 🚦 Verification
After a successful pipeline run, the installation was verified on the VM:
```bash
# Check if Jenkins is active (returns 'active')
sudo systemctl is-active jenkins

# Retrieve the initial admin password to unlock the dashboard
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 🌟 Why this is "Real World"
This project simulates how senior DevOps engineers manage scale. By using **.bicepparam**, the same Bicep logic can deploy to "Dev," "Staging," or "Prod" just by swapping the parameter file. Centralizing secrets in **Key Vault** ensures that if a key is ever compromised, it can be updated in one place without modifying a single line of code.