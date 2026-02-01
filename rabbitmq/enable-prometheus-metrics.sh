# kubectl exec -it <pod-name> -- rabbitmq-plugins enable rabbitmq_management
kubectl exec -it rabbitmqcluster-server-0 -- rabbitmq-plugins enable rabbitmq_management
kubectl exec -it rabbitmqcluster-server-1 -- rabbitmq-plugins enable rabbitmq_management
