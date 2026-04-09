# AI-Powered Bank App with LLM Chatbot

An advanced, Kubernetes-native banking application integrating an AI-powered chatbot for enhanced user interaction. This project demonstrates a modern microservices architecture, utilizing an LLM to assist users with banking inquiries while maintaining a robust, scalable backend powered by a MySQL database and controlled via the automated routing of the Kubernetes Gateway API.

## Architecture Overview

This project is built using a modern containerized approach, orchestrating multiple key components within a Kubernetes cluster:

*   **Backend Service:** The core application logic and LLM-based chatbot interface, handling business operations and processing AI responses.
*   **MySQL Database:** A stateful relational database managing user data, transactions, and chatbot history.
*   **Kubernetes Cluster:** A Minikube-based local environment managing the lifecycle, scaling, and health of all containerized applications.
*   **Gateway API (NGINX Gateway Fabric):** The entry point to our cluster, handling complex routing via `GatewayClass`, `Gateway`, and `HTTPRoute` resources to direct external traffic seamlessly to our backend services.

### Architecture Diagram

```text
               +---------------------------------------------------+
               |               Kubernetes Cluster                  |
+---------+    |   +-------------------------------------------+   |
|         |    |   |               Gateway API                 |   |
|  User   |------->| (GatewayClass -> Gateway -> HTTPRoute)    |   |
|         |    |   +---------------------+---------------------+   |
+---------+    |                         |                         |
               |                         v                         |
               |   +-------------------------------------------+   |
               |   |            Backend Service                |   |
               |   |     (Banking Logic + LLM Chatbot)         |   |
               |   +---------------------+---------------------+   |
               |                         |                         |
               |                         v                         |
               |   +-------------------------------------------+   |
               |   |             MySQL Database                |   |
               |   |           (Stateful Storage)              |   |
               |   +-------------------------------------------+   |
               +---------------------------------------------------+
```

## Prerequisites

Ensure you have the following tools installed before beginning the setup:

*   [Docker](https://docs.docker.com/get-docker/)
*   [Minikube](https://minikube.sigs.k8s.io/docs/start/)
*   [kubectl](https://kubernetes.io/docs/tasks/tools/)
*   [Helm](https://helm.sh/docs/intro/install/) (for NGINX Gateway Fabric installation, if required)

## Setup & Deployment

### Start Minikube

Initialize your local Kubernetes cluster with sufficient resources:

```bash
minikube start --memory=4096 --cpus=2
```

### Apply Kubernetes Manifests

Deploy all application resources (deployments, services, and routing rules) to the cluster from the root directory:

```bash
kubectl apply -f .
```

### Verify Resources

Check the status of the deployed components to ensure everything is running correctly:

```bash
kubectl get pods -A
kubectl get svc -A
kubectl get gateway -A
kubectl get httproute -A
```

## Accessing the Application

### Method 1: Using Minikube Tunnel (Production-like)

This method provides an experience close to a real cloud deployment by assigning an external IP address to the Gateway, simulating a cloud LoadBalancer.

```bash
minikube tunnel
```

Then access the application at:
[http://localhost](http://localhost)

**Why use a tunnel?**
In standard cloud environments, LoadBalancers automatically receive external IP addresses to route outside traffic. Minikube does not natively assign an external IP without using the `tunnel` command. Running the tunnel grants your Gateway a mock external IP, fulfilling the LoadBalancer simulation.

### Method 2: Using Port Forward (Development / Debug)

This method is useful for quick local testing and debugging without needing to configure or simulate an external IP.

```bash
kubectl port-forward -n nginx-gateway svc/ngf-nginx-gateway-fabric 8080:80
```

Then access the application at:
[http://localhost:8080](http://localhost:8080)

**Why use port-forward?**
It directly maps a port on your local machine to the port of the Gateway service inside the cluster. It bypasses the need for an external LoadBalancer IP, making it exceptionally useful for rapid, localized iterative development.

## Key Kubernetes Concepts Used

*   **Gateway API:** A standardized, modern approach for routing traffic into the cluster. We utilize `GatewayClass` to define the controller type, `Gateway` to act as the traffic listener, and `HTTPRoute` to evaluate traffic rules and forward requests based on paths or headers.
*   **backendRefs and Services:** Within `HTTPRoute`, traffic is explicitly directed to specific Kubernetes `Service` definitions via `backendRefs`, cleanly uncoupling routing logic from application deployment logic.
*   **Deployment vs Stateful Apps:** Our stateless Backend service uses a `Deployment` object, allowing dynamic scaling and easy replication. Conversely, MySQL relies on durable storage and ordered handling, necessitating safe, stateful volume configurations to preserve data integrity across restarts.
*   **LoadBalancer in Minikube:** Since Minikube operates locally, standard cloud LoadBalancers cannot natively resolve to accessible external IP addresses. Minikube circumvents this by either exposing NodePorts or leveraging the `tunnel` function to simulate an external LoadBalancer IP.

## Troubleshooting

### Common Issues

*   **CrashLoopBackOff:** A pod is repeatedly crashing upon startup. Check the application logs for missing environment variables, database misconfigurations, or syntax errors.
*   **EXTERNAL-IP pending:** The Gateway or LoadBalancer service is waiting for an IP. Ensure you are running `minikube tunnel` in a separate terminal window and keeping it active.
*   **Gateway PROGRAMMED false:** The NGINX Gateway underlying controller might be missing or misconfigured. Verify that standard Gateway API Custom Resource Definitions (CRDs) are installed.
*   **Connection Reset Errors:** Often occurs immediately after deployment when pods are still warming up, or if the target port in your Service/HTTPRoute mismatches the container port.

### Useful Commands

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events
```

## Project Structure

```text
Bankapp-chatbot-LLM/
├── Dockerfile                  # Application image blueprint
├── Makefile                    # Make commands and automation
├── docker-compose.yml          # Local container composition
├── k8s/                        # Kubernetes manifests and infrastructure
│   ├── deployment.yaml
│   ├── service.yaml
│   └── gateway-api.yaml
├── scripts/                    # Helper scripts for build and setup
├── src/                        # Application source code
│   └── main/                   # Core Java/Spring logic + AI chatbot
├── pom.xml                     # Maven configuration
└── README.md                   # Project documentation
```

## Future Improvements

*   **HTTPS (TLS):** Integrate cert-manager and attach TLS certificates to the Gateway for secure, encrypted external traffic routing.
*   **Canary Deployments:** Leverage Gateway API HTTPRoutes to split traffic (e.g., 90/10) to safely roll out new backend features and LLM model upgrades.
*   **Scaling with StatefulSets:** Migrate entirely to robust `StatefulSet` resources with Persistent Volume Claims for production-hardened MySQL durability, allowing safe replication and backups.
