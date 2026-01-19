---
layout: page
title: Posts
---

<ul class="post-list">
  <% collections.posts.each do |post| %>
    <li>
     <%= render PostPreview.new(post:) %>
    </li>
  <% end %>
</ul>