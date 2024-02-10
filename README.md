<h1>☁️ Azure Dev Environment</h1>

<h3>Project Overview</h3>
<p>Used Terraform to create a Linux VM Dev environment in Azure. Terraform was used to interact with my Azure tenant to create a resource group, virtual network, subnet, Network security group, virtual NIC and the Public Linux VM that I can SSH into using the VSCODE's Remote-SSH extension.</p>

<h4>Language/Software Used</h4>
Terraform v1.6.6</br>
Visual Studio Code (<a href=https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh>Remote-SSH Extension Installed</a>)

</br><p><b>⚠️ Remote-SSH opens a remote connection between your host machine and the remote VM. Only ever connect to a remote machine that you either own or trust. Compromised remote machines can execute code remotely on your system without your knowledege.</b> </p> 
<h3>Connecting to Azure Linux VM</h3>

<p>Remote-SSH allows us to make connections to known host via <i>~/.ssh/config</i>. We modify this config using the <i>windows-ssh-script.tpl</i> which will append new connections whenever we rebuild the target Linux VM. This is handled by the 'provisioner' from Terraform which allows us to execute a local script whenever the 'azurerm_linux_virtual_machine' resource is created.</p>

<h5>windows-ssh-script.tpl</h5>

```
add-content -path c:/users/smoke/.ssh/config -value @'
Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${IdentityFile}
'@
```

