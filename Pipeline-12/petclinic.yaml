apiVersion: apps/v1
kind: Deployment
metadata:
  name: luckywebapp
  labels:
    app: luckywebapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: luckywebapp
  template:
    metadata:
      labels:
        app: luckywebapp
    spec:
      imagePullSecrets:
        - name: acr-secret  # Ensure this matches your Kubernetes secret name for ACR
      containers:
      - name: luckywebapp
        image: luckyregistry.azurecr.io/my-app-image:latest
        ports:
        - containerPort: 8080  # FIXED: Match internal app port

---

apiVersion: v1
kind: Service
metadata:
  name: luckywebapp-service
spec:
  type: LoadBalancer
  selector:
    app: luckywebapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080  # FIXED: Route to correct internal port
