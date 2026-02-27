package com.aura.backend.controller;

import com.aura.backend.model.Post;
import com.aura.backend.security.services.UserDetailsImpl;
import com.aura.backend.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/posts")
public class PostController {

    @Autowired
    private PostService postService;

    @GetMapping
    public List<Post> getFeed() {
        return postService.getAllPosts();
    }

    @GetMapping("/user/{userId}")
    public List<Post> getUserPosts(@PathVariable Long userId) {
        return postService.getUserPosts(userId);
    }

    @PostMapping
    public ResponseEntity<Post> createPost(@RequestBody PostRequest request) {
        UserDetailsImpl userDetails = (UserDetailsImpl) SecurityContextHolder.getContext().getAuthentication()
                .getPrincipal();
        Post post = postService.createPost(userDetails.getUsername(), request.caption, request.mediaUrl);
        return ResponseEntity.ok(post);
    }

    @PostMapping("/{postId}/like")
    public ResponseEntity<?> likePost(@PathVariable Long postId) {
        UserDetailsImpl userDetails = (UserDetailsImpl) SecurityContextHolder.getContext().getAuthentication()
                .getPrincipal();
        postService.likePost(postId, userDetails.getUsername());
        return ResponseEntity.ok("Post liked");
    }

    @DeleteMapping("/{postId}/like")
    public ResponseEntity<?> unlikePost(@PathVariable Long postId) {
        UserDetailsImpl userDetails = (UserDetailsImpl) SecurityContextHolder.getContext().getAuthentication()
                .getPrincipal();
        postService.unlikePost(postId, userDetails.getUsername());
        return ResponseEntity.ok("Post unliked");
    }

    @PostMapping("/{postId}/comments")
    public ResponseEntity<?> addComment(
            @PathVariable Long postId,
            @RequestBody CommentRequest request) {
        UserDetailsImpl userDetails = (UserDetailsImpl) SecurityContextHolder.getContext().getAuthentication()
                .getPrincipal();
        return ResponseEntity.ok(postService.addComment(postId, userDetails.getUsername(), request.content));
    }

    @GetMapping("/{postId}/comments")
    public List<com.aura.backend.model.Comment> getComments(@PathVariable Long postId) {
        return postService.getComments(postId);
    }

    public static class PostRequest {
        public String caption;
        public String mediaUrl;
    }

    public static class CommentRequest {
        public String content;
    }
}
