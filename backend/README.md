# Aura App Backend

This is the Java Spring Boot backend for the Aura application.

## Prerequisites

- **Java 17** or higher installed (`java -version`)
- **Maven** installed (`mvn -version`)
- **MySQL Database** running on `localhost:3306`

## Setup Database

1.  Open your MySQL client (Workbench, CLI, etc.).
2.  Create the database:
    ```sql
    CREATE DATABASE aura_db;
    ```
3.  Update database credentials in `src/main/resources/application.properties`:
    ```properties
    spring.datasource.username=root
    spring.datasource.password=YOUR_PASSWORD
    ```

## How to Run

1.  Open a terminal in this `backend` directory.
2.  Run the application using3.  **Run (using local Maven)**:
    Since `mvn` is not in your global path, use the downloaded local version:
    ```bash
    ..\maven\apache-maven-3.9.6\bin\mvn spring-boot:run
    ```
    *Make sure you run this from inside the `backend` folder.*
3.  The server will start at `http://localhost:8080`.

## API Endpoints

### Authentication

-   **Register**: `POST /api/auth/register`
    ```json
    {
      "username": "testuser",
      "email": "test@example.com",
      "password": "password123"
    }
    ```
-   **Login**: `POST /api/auth/login`
    ```json
### Stories

-   **Get Feed**: `GET /api/stories/feed` (Requires Auth)
-   **Create Story**: `POST /api/stories` (Requires Auth)
    ```json
    {
      "mediaUrl": "https://example.com/image.jpg",
      "mediaType": "IMAGE"
    }
    ```

### Posts

-   **Get Feed**: `GET /api/posts`
-   **Create Post**: `POST /api/posts` (Requires Auth)
    ```json
    {
      "caption": "Hello World",
      "mediaUrl": "https://example.com/image.jpg"
    }
    ```
-   **Like Post**: `POST /api/posts/{id}/like` (Requires Auth)
-   **Unlike Post**: `DELETE /api/posts/{id}/like` (Requires Auth)
-   **Add Comment**: `POST /api/posts/{id}/comments` (Requires Auth)
    ```json
    {
      "content": "Nice post!"
    }
    ```
-   **Get Comments**: `GET /api/posts/{id}/comments`
  