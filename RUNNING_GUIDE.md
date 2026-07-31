# CampusKart & Campus Pulse Running Guide

This guide provides step-by-step instructions to bring up the entire CampusKart ecosystem, including Jenkins, Kubernetes (Minikube), the FastAPI backend, the React Dashboard (public-view), and the Flutter mobile app.

---

## 🏗️ Step 1: Start Jenkins (Terminal 1)
Jenkins is responsible for automatically building your Docker images and deploying them to Kubernetes whenever you push code to GitHub.

Open your first terminal, navigate to where your `jenkins.war` file is located, and run:

cd "C:\Program Files\Jenkins"
```powershell
java -jar jenkins.war --httpPort=8080
```
- Keep this terminal open.
- Wait until you see the message **"Jenkins is fully up and running"**.
- Jenkins is now listening on `http://localhost:8080`.

---

## 🐳 Step 2: Start Minikube (Terminal 2)
Since your backend and React dashboard run on Kubernetes, you need to start Minikube via WSL.

Open a second terminal and run:
```powershell
wsl minikube start
```
- Ensure Docker Desktop is running before you execute this.
- Wait for Minikube to finish configuring the cluster.

*(Note: Whenever you push changes to GitHub, Jenkins will automatically use Minikube to build your new Docker images and update the Kubernetes pods!)*

---

## 🌐 Step 3: Expose the React Dashboard (Terminal 3)
To access your web-based Control Center (Dashboard), you need to expose its Kubernetes service.

Open a third terminal and run:
```powershell
wsl minikube service campuskart-frontend-service
```
- **IMPORTANT:** Because you are using a Docker driver on Linux (WSL), **you must keep this terminal open!** If you close it, the tunnel will collapse and the page will go down.
- Minikube will print a local URL (e.g., `http://127.0.0.1:35201`).
- You can now open this URL in your browser to view the dashboard! *(The dashboard will automatically proxy API requests to the backend for you).*

---

## ⚙️ Step 4: Expose the Backend Service (Terminal 4)
The backend is needed for the mobile app to function. You must expose the FastAPI Kubernetes service so your local machine can access it.

Open a fourth terminal and run:
```powershell
wsl minikube service campuskart-backend-service
```
- **IMPORTANT:** Again, **keep this terminal open!**
- Minikube will print a local URL (e.g., `http://127.0.0.1:41273`).
- Note down the **port number** (in this example, `41273`). You will need it for the next step.

---

## 🌍 Step 5: Expose the Backend to the Internet via Ngrok (Terminal 5)
Your Flutter mobile app needs to communicate with the backend, which is easiest when the backend has a public HTTPS URL. 

Open a fifth terminal and run ngrok, replacing `<PORT>` with the port number you got in Step 4:
```powershell
ngrok http <PORT>
# Example: ngrok http 41273
```
- Keep this terminal open.
- Ngrok will give you a Forwarding URL (e.g., `https://dawdlingly-pseudoinsane-pa.ngrok-free.dev`).
- **Make sure this Ngrok URL matches the URL configured in your Flutter app's API settings!**

---

## 📱 Step 6: Run the Flutter Mobile App (Terminal 6)
Finally, start the Campus Pulse mobile application.

Open a sixth terminal, navigate to your Flutter project folder, and run:
```powershell
cd C:\Users\ASUS\Desktop\Projects\CampusKart\frontend
flutter run
```
- Ensure your Android Emulator is running or your physical device is connected.
- Select your device when prompted.

---

## 📊 Step 7: Access Prometheus & Grafana Dashboards (Terminal 7 & 8)
To monitor your cluster's health and metrics, you can access the Prometheus and Grafana dashboards deployed via Helm.

### Option A: Open Prometheus UI (Terminal 7)
If you want to run direct metric queries:
Open a seventh terminal and run:
```powershell
wsl kubectl port-forward service/prometheus-server 9090:80
```
- Open your browser to: **`http://localhost:9090`**

### Option B: Open Grafana Dashboard (Terminal 8)
Open an eighth terminal and run:
```powershell
wsl kubectl port-forward service/grafana 3000:80
```
- Open your browser to: **`http://localhost:3000`**
- *Login:* The default username is usually `admin`. To get the auto-generated password, run: `wsl kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode`

**Connecting Grafana to Prometheus:**
When Grafana asks for the Prometheus URL, **do NOT use localhost:9090**! Because both are running inside Kubernetes, they can talk to each other directly using Kubernetes' internal network. 
- In Grafana Data Sources, set the URL to exactly: **`http://prometheus-server:80`**

---

### 🎉 You are all set!
As long as these terminals remain open, your entire local ecosystem will run smoothly. When you're done for the day, you can safely press `Ctrl + C` in the terminals to shut down the tunnels, ngrok, Jenkins, and port forwards.
