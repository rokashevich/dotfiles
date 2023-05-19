k create ns my-jenkins
 k --namespace=my-jenkins create secret generic github --from-literal=token='VALUE'