<h1>☁️ Azure Dev Environment</h1>

<h3>Project Overview</h3>
<p>Used Terraform to create a Linux VM Dev environment in Azure. Terraform was used to interact with my Azure tenant to create a resource group, virtual network, subnet, Network security group, virtual NIC and the Public Linux VM that I can SSH into using the VSCODE's Remote-SSH extension.</p>

<h4>Language/Software Used</h4>
<a href=https://developer.hashicorp.com/terraform/install>Terraform v1.6.6</a></br>
Visual Studio Code (<a href=https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh>Remote-SSH Extension Installed</a>)

<h4>Prerequisite</h4>

+ Azure account is needed, you can get a free trial @ https://azure.microsoft.com/en-us/pricing/offers/ms-azr-0044p </br>

+ You will need to generate a SSH keypair in order to authenicate with your Linux VM. Within your terminal you can run the following command in your terminal to generate a keypair. You can follow the <a href=https://www.ssh.com/academy/ssh/keygen>Official Documentation Here</a>

```
ssh-keygen -t rsa
```

___

<h3>Connecting to Azure Linux VM</h3>

> [!CAUTION]
> Remote-SSH opens a remote connection between your host machine and the remote VM. Only ever connect to a remote machine that you either own or trust. Compromised remote machines can execute code remotely on your system without your knowledege.

<p>Remote-SSH allows us to make connections to known host via <i>~/.ssh/config</i>. We modify this config using the <i>windows-ssh-script.tpl</i> which will append new connections whenever we rebuild the target Linux VM. This is handled by the 'provisioner' from Terraform which allows us to execute a local script whenever the <i>azurerm_linux_virtual_machine</i> resource is created.</p>

<h5>windows-ssh-script.tpl</h5>

```
add-content -path c:/users/smoke/.ssh/config -value @'
Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${IdentityFile}
'@
```
After building out the <i>azurerm_linux_virtual_machine</i> resource you can now connect and open up the Remote-SSH tool using <i>CTRL+SHIFT+P</i> > <i>Remote-SSH: Connect to Host...</i> > <i>172.176.112.222</i> (This is the public ip assignment for this VM, your ip address will differ from what is shown here) > A new VSCODE instance will open | <i>Select the OS of the remote Host - Linux </i> > <i>You are now SSH'd into the remote machine</i>
</br>
![image](https://github.com/AntonioTanco/Terraform-Dev-Environment---Azure/assets/43735570/fcf09e1b-a28e-47b9-977e-ae0db35a4cf9)
![image](https://github.com/AntonioTanco/Terraform-Dev-Environment---Azure/assets/43735570/34a45111-9fae-42f0-b259-707587e9d587)
![image](https://github.com/AntonioTanco/Terraform-Dev-Environment---Azure/assets/43735570/6ef20c73-a75c-44c9-ad8b-4b180d8d012e)




