terraform { 
  cloud { 
    organization = "Hashi-RedHat-APJ-Collab" 

    workspaces { 
      name = "watsonx_approle" 
    } 
  } 
}