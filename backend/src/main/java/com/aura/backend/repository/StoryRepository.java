package com.aura.backend.repository;

import com.aura.backend.model.Story;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface StoryRepository extends JpaRepository<Story, Long> {
    // Find valid stories (not expired) for a specific user
    List<Story> findByUserIdAndExpiresAtAfter(Long userId, LocalDateTime now);

    // Find valid stories for a list of users (e.g., followed users)
    List<Story> findByUserIdInAndExpiresAtAfter(List<Long> userIds, LocalDateTime now);
}
