# Project Architecture & Developer Notes

## 1. Project Overview
This project, **AURA**, is a comprehensive social media application consisting of two main components:
-   **Backend**: A robust Java Spring Boot application providing RESTful APIs, handling authentication, data persistence, and business logic.
-   **Frontend**: A modern, high-performance Flutter application delivering a rich user experience.

---Thought for 7s





## 2. Java Backend: How It Was Built

### Technology Stack
-   **Language**: Java 17
-   **Framework**: Spring Boot 3.2.2
-   **Build Tool**: Maven
-   **Database**: MySQL
-   **Security**: Spring Security + JWT (JSON Web Tokens)

### Architectural Layers
The backend follows the standard Controller-Service-Repository pattern:

1.  **Controller Layer** (`com.aura.backend.controller`)
    -   **Role**: Handles incoming HTTP requests (GET, POST, etc.) and returns responses (JSON).
    -   **Key Components**:
        -   `AuthController`: Manages Login and Register endpoints.
        -   `PostController`: Handles creating, liking, and fetching posts.
        -   `StoryController`: Manages user stories.
    -   **Refactoring work**: We migrated from manual token parsing to using Spring Security's `SecurityContextHolder` to securely identify the currently logged-in user.

2.  **Service Layer** (`com.aura.backend.service`)
    -   **Role**: Contains the business logic. It translates controller requests into database operations.
    -   **Key Components**: `UserService`, `PostService`, `StoryService`.

3.  **Repository Layer** (`com.aura.backend.repository`)
    -   **Role**: The interface to the Database.
    -   **Implementation**: Extends `JpaRepository`. Spring Data JPA automatically generates SQL queries based on method names (e.g., `findByUsername`).

4.  **Security Layer** (`com.aura.backend.security`)
    -   **Role**: Secures the application to ensure only authenticated users can access protected resources.
    -   **Implementation Details**:
        -   **JWT (JSON Web Token)**: Used for stateless authentication. When a user logs in, they receive a token. This token must be sent in the header of subsequent requests.
        -   **`AuthTokenFilter`**: A custom filter that intercepts every request, checks for a valid JWT, and sets the user's identity in the Security Context.
        -   **`SecurityConfig`**: The main configuration file that defines which endpoints are public (auth/*) and which require login.

### Key Aspects of Key Extensions
-   **`UserDetailsServiceImpl`**: Bridges our custom `User` entity with Spring Security's `UserDetails` interface, allowing Spring to understand our users.
-   **`AuthEntryPointJwt`**: Handles unauthorized access errors (returning 401 Unauthorized signals).

---

## 3. Flutter Frontend Integration

### Current Status
The Flutter frontend currently features a polished UI implementation using **Mock Data** (static lists and placeholder images). The API integration layer is ready to be connected.

### Integration Strategy: How to "Add" the Frontend to the Backend

To fully connect the Flutter frontend to the Java backend, the following steps effectively bridge the two:

1.  **Networking Client**
    -   **Concept**: Flutter needs a way to send HTTP requests to `http://localhost:8080/api`.
    -   **Implementation**: Use the `http` package or `dio`.
    -   **Action**: Create a centralized `ApiService` class in `lib/core/api/` that handles base URLs, headers (adding the JWT), and error handling.

2.  **Data Models**
    -   **Concept**: Dart classes must mirror the Java Entities.
    -   **Action**: Create Dart models for `User`, `Post`, and `Story` with `fromJson` and `toJson` methods to convert internal objects to JSON for the API.

3.  **Authentication Flow**
    -   **Login**:
        1.  User enters credentials in Flutter.
        2.  Flutter sends POST to `/api/auth/login`.
        3.  Backend returns a JWT String.
        4.  Flutter saves this JWT (using `flutter_secure_storage` or `shared_preferences`).
    -   **Protected Calls**: For every subsequent request (e.g., "Create Post"), Flutter retrieves the saved JWT and adds it to the HTTP Header: `Authorization: Bearer <token>`.

### Integration Roadmap
1.  **Define API Service**: Create `lib/services/api_service.dart`.
2.  **Connect Auth**: Hook up the Login/Register forms to call `apiService.login()`.
3.  **Replace Mocks**: specific widgets like `HomeFeed` (in `home_feed.dart`) should fetch data from `apiService.getFeed()` instead of generating `List.generate` mock data.

---

## 4. Key Java Concepts Used
-   **Annotations (`@Component`, `@Autowired`, `@Service`)**: "Magic" markers that tell Spring Boot to manage these classes (Dependency Injection).
-   **JPA/Hibernate**: The ORM (Object-Relational Mapping) tool that lets us treat Database rows as Java Objects.
-   **Streams & Lambdas**: Used often in the Service layer for efficient data processing.
-   **Stateless Authentication**: The server does not remember the user between requests; the Token (JWT) proves identity every time.
