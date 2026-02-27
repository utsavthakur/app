package com.aura.backend.controller;

import com.aura.backend.model.Story;
import com.aura.backend.security.services.UserDetailsImpl;
import com.aura.backend.service.StoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/stories")
public class StoryController {

    @Autowired
    private StoryService storyService;

    // Get stories for the current user's feed (followed users + self)
    // For now, just returns active stories for the current user to keep it simple
    // We can also use @AuthenticationPrincipal here if we wanted to authorize based
    // on user
    @GetMapping("/feed")
    public List<Story> getStoryFeed() {
        // In a real app, we'd extract user ID from token/context, find followed users,
        // and get
        // their stories.
        return List.of();
    }

    @PostMapping
    public ResponseEntity<Story> createStory(@RequestBody StoryRequest request) {
        UserDetailsImpl userDetails = (UserDetailsImpl) SecurityContextHolder.getContext().getAuthentication()
                .getPrincipal();
        Story story = storyService.createStory(userDetails.getUsername(), request.mediaUrl, request.mediaType);
        return ResponseEntity.ok(story);
    }

    // DTO for request
    public static class StoryRequest {
        public String mediaUrl;
        public Story.MediaType mediaType;
    }
}
