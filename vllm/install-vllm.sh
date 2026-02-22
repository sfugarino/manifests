helm upgrade --install vllm vllm/vllm-stack \
     -f values.yaml \
     --namespace vllm \
     --create-namespace
