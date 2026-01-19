# frozen_string_literal: true

class PostPreview < Bridgetown::Component
  def initialize(post:)
    @post = post
  end

  def template
    html -> { <<~HTML
      <article class="post-preview">
        <h2><a href="#{@post.relative_url}">#{@post.data.title}</a></h2>
        <p class="post-preview__date">#{@post.date.strftime('%B %d, %Y')}</p>
        <p class="post-preview__description">#{@post.data.description}</p>
      </article>
    HTML
    }
  end
end
