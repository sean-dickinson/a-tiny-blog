---
layout: post
title:  "Feature Flags"
date:   2025-11-03 19:04:11 -0500
categories: php ruby
published: false
---
Feature flags allow customizing what code is run based on various conditions such as the environment, the current user, or whatever you like.
In psuedo-code, a feature flag could like this:

```php
if (feature_flag_enabled("new-api")) {
    // Use the new API
} else {
    // Use the old API
}
```

Now you might be saying, that's just an if statement, and you'd be right! However, the key difference is that feature flags are usually backed by some sort of system to allow for more granular control over when a feature is enabled or disabled.
You could absolutely implement your own feature flags using hard coded variables, or maybe environment variables and that would be a valid approach for some use cases.

Personally, I find feature flags to be very helpful when using a trunk based development workflow, as they allow merging in features that might be incomplete or not ready for prime-time without affecting the production behavior of the application.
This allows for smaller, more frequent merging into the main branch without needing to bend over backwards when a hotfix needs to get released. Your main branch can always be deployable, even if some features are not yet ready to be turned on.

It is also possible to use feature flags for other more advanced workflows, such as A/B testing, beta features, or gradual rollouts. But in my day-to-day work, this use case is not one that I find myself needing very often.
I won't say I *never* need to implement A/B testing, but I wouldn't build a feature flagging system around with that use-case as the fundamental tenant. Speaking of which...

## Laravel Pennant
Laravel provides a first party package for feature flags called [Pennant](https://laravel.com/docs/pennant).

Laravel's implementation appears to be focused more on using feature flags for... A/B testing. Here is how it works:
- You define a "Feature", which is just a label (like "new-api"), that accepts a closure that determines if the feature is enabled or not for the given context (which is usually the current user).
- You can then check if the feature is enabled at any point in your code, ond branch accordingly (like the psuedo-code example above).
- The closure is only executed once per user, and the result is cached *forever* (or at least until you manually clear it).

Here's some example code that defines a feature

```php
# in a service provider's boot method
Feature::define('new-api', fn (User $user) => match (true) {
    $user->isInternalTeamMember() => true,
    $user->isHighTrafficCustomer() => false,
    default => Lottery::odds(1 / 100),
});
```

And here's how you would check if the feature is enabled:

```php
// Implicitly uses the current user context
if (Feature::active('new-api') {
    // Use the new API
} else {
    // Use the old API
}
```

If you are doing A/B testing, this is a great system. The default assumptions are that you want to check if a feature should be enabled for a certain user.
It provides customization so you can have some features fully enabled for certain users, fully disabled for others, and randomly enabled for a percentage of users like you would in a traditional A/B test.
The caching of the resolved value also makes sense in this context, as you don't want a user to be getting different variants of a feature across requests.

But what about my simple use case for feature flags? I want to ship some code that is not yet ready to be enabled for everyone, but I want to be able to toggle it on or off globally without needing to remote into a server or deploy new code.
That's not really something Laravel Pennant is designed to do out of the box. They offer us an artisan command to purge the cached resolved values, but that is a manual process that requires server access.
They offer that you might consider doing this on every deployment? But then you need to deploy code to just change the state of a feature flag for a user who has already had the value resolved.

If we think about this with an example:
- You build a new feature. You want the stakeholder to be able to test it in production before you do a full rollout.
- You create the feature in Pennant, with the logic that it is enabled for stakeholders, disabled for everyone else.
- You deploy the code to production.
- The stakeholder can test the feature, and then they say it's good and you can roll it out, but be ready to roll it back in case something goes wrong
- You update the feature logic to enable it for everyone
- You redeploy the code (and remember to purge the cache)
- If you need to rollback you need to...redeploy and purge the cache again.

The beauty of a feature flag in my opinion is that you should be able to toggle it on or off without needing to do any code deployments or server commands.
We *could* build a custom UI on top of Pennant do this, but if most of your features are globally enabled or disabled, that seems like a lot of extra work for something that should be simple.

## Tell me what you want, what you really, really want

Let's think about what features I would want in a feature flag system.
- Feature flags should be able to be globally enabled or disabled with requiring a "current user"
- Feature flags should be able to be managed via a simple UI so that they do not require code deployments or remote server commands to toggle them
- Feature flags should be (optionally) be able to be enabled/disabled for a specific user group. Usually this same group would be reused between features (admin users, stakeholders, developers,) etc)

Why do we want this again?
- Merging in unfinished code to production without risk
- Avoiding long-running feature branches
- Allowing features to be toggled for specific users or groups for testing purposes (mostly for stakeholder validation on production before a full rollout)
- Quickly rolling back features without needing to do code deployments or server commands if something goes wrong
- Dealing with awkward refactors that require multiple deployments to fully implement (schema migrations, data backfills, etc.)

If I'm being honest, this isn't something I dreamed up. It's something I've experienced while using a tool that provides these capabilities. 
The only problem is that this tool is a Ruby gem called [Flipper](https://github.com/flippercloud/flipper) which I can't use when working in PHP/Laravel projects.

Flipper provides a simple way to define feature flags, and then manage them via a provided UI. They more recently added a cloud offering which allows you to optionally sync feature flag states between environments, which is nice but honestly not a requirement for my use case.

