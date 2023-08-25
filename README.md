### Bulutbilisimciler base shell session images  
This repository contains image Dockerfiles that use in bulutbilisimciler.com shell sessions  
  
#### Images  
- [X] Sample (Main)  
- [ ] Go   
- [ ] Java   
- [ ] Mongo   
- [ ] Postgres   
- [ ] Nodejs   
- [ ] Minikube   
  
  
#### Image standarts  
1. For Cluster Images:  
    - control-plane:/home/root (master) 
    - worker:/home/root (follower)  
2. For Development Image: 
    - Go:/home/bb (root)
    - Nodejs:/home/bb (root)
    - ...  

  
#### Build Command  
- `docker buildx build --platform linux/amd64 -t alperreha/bb:sample-python-v3.8 .`  
- `docker push alperreha/bb:sample-python-v3.8`  
