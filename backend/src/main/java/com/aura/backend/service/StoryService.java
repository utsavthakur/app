package com.aura.backend.service;

import com.aura.backend.model.Story;
import com.aura.backend.model.User;
import com.aura.backend.repository.StoryRepository;
import com.aura.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class StoryService {

    @Autowired
    private StoryRepository storyRepository;

    @Autowired
    private UserRepository userRepository;

    public Story createStory(String username, String mediaUrl, Story.MediaType mediaType) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Story story = new Story();
        story.setUser(user);
        story.setMediaUrl(mediaUrl);
        story.setMediaType(mediaType);

        return storyRepository.save(story);
    }

    public List<Story> getActiveStoriesForUser(Long userId) {
        return storyRepository.findByUserIdAndExpiresAtAfter(userId, LocalDateTime.now());
    }

    public List<Story> getFeedStories(List<Long> followingIds) {
        return storyRepository.findByUserIdInAndExpiresAtAfter(followingIds, LocalDateTime.now());
    }
}
