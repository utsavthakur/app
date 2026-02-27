package com.aura.backend.service;

import com.aura.backend.model.Post;
import com.aura.backend.model.User;
import com.aura.backend.repository.PostRepository;
import com.aura.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PostService {

    @Autowired
    private PostRepository postRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private com.aura.backend.repository.LikeRepository likeRepository;

    @Autowired
    private com.aura.backend.repository.CommentRepository commentRepository;

    public Post createPost(String username, String caption, String mediaUrl) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Post post = new Post();
        post.setUser(user);
        post.setCaption(caption);
        post.setMediaUrl(mediaUrl);

        return postRepository.save(post);
    }

    public List<Post> getAllPosts() {
        // Return all posts for global feed or filter by following (MVP: all posts)
        return postRepository.findAll();
    }

    public List<Post> getUserPosts(Long userId) {
        return postRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public void likePost(Long postId, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        if (!likeRepository.existsByPostIdAndUserId(postId, user.getId())) {
            com.aura.backend.model.Like like = new com.aura.backend.model.Like();
            like.setPost(post);
            like.setUser(user);
            likeRepository.save(like);

            post.setLikeCount(post.getLikeCount() + 1);
            postRepository.save(post);
        }
    }

    public void unlikePost(Long postId, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        if (likeRepository.existsByPostIdAndUserId(postId, user.getId())) {
            likeRepository.findByPostIdAndUserId(postId, user.getId())
                    .ifPresent(like -> likeRepository.delete(like));

            post.setLikeCount(Math.max(0, post.getLikeCount() - 1));
            postRepository.save(post);
        }
    }

    public com.aura.backend.model.Comment addComment(Long postId, String username, String content) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        com.aura.backend.model.Comment comment = new com.aura.backend.model.Comment();
        comment.setPost(post);
        comment.setUser(user);
        comment.setContent(content);

        com.aura.backend.model.Comment savedComment = commentRepository.save(comment);

        post.setCommentCount(post.getCommentCount() + 1);
        postRepository.save(post);

        return savedComment;
    }

    public List<com.aura.backend.model.Comment> getComments(Long postId) {
        return commentRepository.findByPostIdOrderByCreatedAtAsc(postId);
    }
}
