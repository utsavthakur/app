package com.aura.backend.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "stories")
public class Story {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String mediaUrl;

    @Enumerated(EnumType.STRING)
    private MediaType mediaType;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        // Stories expire in 24 hours by default
        if (expiresAt == null) {
            expiresAt = LocalDateTime.now().plusHours(24);
        }
    }

    public enum MediaType {
        IMAGE, VIDEO
    }
}
