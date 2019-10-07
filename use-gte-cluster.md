## Get CLIs
<<<<<<< HEAD
  1. awscli
=======
  1. **awscli** - The AWS Command Line Interface (CLI) is a unified tool to manage your AWS services.
>>>>>>> 70f0ed0988653ea255c571f2578719bcabfa3810
    
      ```
      brew install python3
      pip3 install awscli --upgrade --user
      ```
<<<<<<< HEAD

  2. kubectl:
https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-macos
=======
      Verify the install was successful by running the following command:
      ```
      aws help
      ```

  2. **kubectl** - The Kubernetes command-line tool, kubectl, allows you to run commands against Kubernetes clusters. You can use kubectl to deploy applications, inspect and manage cluster resources, and view logs.

      Installation Document [Link](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-macos)

      On Mac:
      ```
      brew install kubectl
      ```

      On Linux:
>>>>>>> 70f0ed0988653ea255c571f2578719bcabfa3810
      ```
      curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl

      chmod +x ./kubectl

      sudo mv ./kubectl /usr/local/bin/kubectl

      KUBECONFIG="$HOME/.kube/config"
<<<<<<< HEAD

=======
      ```
      Verify the install was successful by running the following command:
      ```
>>>>>>> 70f0ed0988653ea255c571f2578719bcabfa3810
      kubectl version
      ```
      > make sure the file at `$HOME/.kube/config` is valid, you may have to delete and recreate it. 
  
<<<<<<< HEAD
  3. kubectx: 
      ```
      brew install kubectx
      ```
      > i think this is missing one word.
=======
  3. **kubectx** - a tool to switch between Kubernetes contexts

      A Kubernetes context is a group of access parameters. Each context contains a Kubernetes cluster, a user, and a namespace. The current context is the cluster that is currently the default for kubectl
      ```
      brew install kubectx
      ```
>>>>>>> 70f0ed0988653ea255c571f2578719bcabfa3810

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
