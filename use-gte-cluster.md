## Get CLIs
  1. awscli
    
      ```
      brew install python3
      pip3 install awscli --upgrade --user
      ```

  2. kubectl:
https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-macos
      ```
      curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl

      chmod +x ./kubectl

      sudo mv ./kubectl /usr/local/bin/kubectl

      KUBECONFIG="$HOME/.kube/config"

      kubectl version
      ```
      > make sure the file at `$HOME/.kube/config` is valid, you may have to delete and recreate it. 
  
  3. kubectx: 
      ```
      brew install kubectx
      ```
      > i think this is missing one word.

## Configure environment
1. Request AWS key/secret + namespace from EKS Admin
2. Configure `aws` to use correct profile:
      ```
      aws configure --profile ping-cloud-${USER}
      ```

    Set created profile as default for current shell: 

    ```
    export AWS_DEFAULT_PROFILE=ping-cloud-${USER}
    ```

3. Add the kubernetes context to your kubectl config. 
    ```
    aws eks --region us-east-2 update-kubeconfig --name ping-devops-gte
    ```

4. Set the new context and namespace:
    
    Find the new context
    
      ```
      kubectx 
      ```
      >one should look familiar.. 
    
    rename it so it's easier to find
      ```
      kubectx ping-devops-gte=<name_from_above>
      ```
    Set the namespace (we are using "ping-poc-intuit")
      ```
      kubens ping-cloud-${USER}
      ```

5.  Test!: 
    ```
    kubectl create deployment hello-node --image=gcr.io/hello-minikube-zero-install/hello-node
    ```
    > Note: look to see that this deployment is attached to your namespace. 
    ```
    kubectl delete deployment hello-node
    ```
    
## Deploy Ping Cloud Base!
1. set your env
    ```
    export TENANT=
2. clone the repo
    ```
    git clone https://github.com/pingidentity/ping-cloud-base.git
    ```

3. run ./dev-env.sh
    ```
    cd ping-cloud-base
    ./dev-env.sh
