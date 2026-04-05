# Running the Three-Tier Web Architecture Project

This guide provides simplified steps to run the application both locally and on AWS.

## Prerequisites
- **Node.js**: Version 16.x is recommended.
- **MySQL**: Either a local instance or an AWS Aurora/RDS instance.

---

## 1. Database Setup

Login to your MySQL shell and run:

```sql
CREATE DATABASE webappdb;
USE webappdb;

CREATE TABLE IF NOT EXISTS transactions (
  id INT NOT NULL AUTO_INCREMENT, 
  amount DECIMAL(10,2), 
  description VARCHAR(100), 
  PRIMARY KEY(id)
);

-- Optional: Seed initial data
INSERT INTO transactions (amount, description) VALUES ('400', 'groceries');
```

---

## 2. Running the Application Tier (Backend)

1.  Navigate to the app tier directory:
    ```bash
    cd application-code/app-tier
    ```
2.  Install dependencies:
    ```bash
    npm install
    ```
3.  Configure your environment:
    ```bash
    cp .env.example .env
    ```
    Edit the `.env` file with your database credentials.
4.  Start the application:
    - **Local/Development**:
      ```bash
      node index.js
      ```
    - **Production (AWS)**:
      ```bash
      pm2 start index.js
      ```

The backend will be available at `http://localhost:4000`.

---

## 3. Running the Web Tier (Frontend)

1.  Navigate to the web tier directory:
    ```bash
    cd application-code/web-tier
    ```
2.  Install dependencies:
    ```bash
    npm install
    ```
3.  Start the application:
    - **Local/Development**:
      ```bash
      npm start
      ```
      The frontend will be available at `http://localhost:3000`.
    - **Production (AWS)**:
      ```bash
      npm run build
      ```
      This will generate a `build/` folder. You will then serve this using Nginx as described in the `nginx.conf`.

---

## 4. Deployment on AWS (Nginx)

When deploying to an EC2 instance:
1.  Install Nginx.
2.  Update `/etc/nginx/nginx.conf` with the contents of the `application-code/nginx.conf` provided in this project.
    - **Note**: Ensure the `upstream` directive points to your Internal Load Balancer DNS.
3.  Restart Nginx:
    ```bash
    sudo systemctl restart nginx
    ```

---

> [!TIP]
> For a full step-by-step AWS infrastructure walkthrough, please refer to the [Implementation_Steps.md](file:///Users/ankitanupamrout/git/Three-Tier-Achitecture-AWS/Implementation_Steps.md) file.
