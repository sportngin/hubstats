module Hubstats
  class EventsHandler

    # Public - Processes comments and PRs
    #
    # payload - the data that we will be processing
    # type - the type of data that payload is
    #
    # Returns - nothing
    def route(payload, type)
      case type
      when "issue_comment", "IssueCommentEvent"
        comment_processor(payload, "Issue")
      when "commit_comment", "CommitCommentEvent"
        comment_processor(payload, "Commit")
      when "pull_request", "PullRequestEvent"
        pull_processor(payload)
      when "pull_request_review_comment", "PullRequestReviewCommentEvent"
        comment_processor(payload, "PullRequest")
      when "membership", "MembershipEvent"
        team_processor(payload)
      end
    end

    # Public - Gets the information for the PR, creates/updates the new PR, grabs the labels, and makes new labels;
    #  if the label qa-approved is added or removed, a new QA Signoff record will be made
    #
    # payload - the information that we will use to get data off of
    #
    # Returns - nothing, but creates/updates the PR and adds appropriate labels
    def pull_processor(payload)
      pull_request = payload[:pull_request]
      pull_request[:repository] = payload[:repository]
      new_pull = Hubstats::PullRequest.create_or_update(pull_request.with_indifferent_access)
      if payload[:github_action].include?('labeled')
        if payload[:github_action].include?('unlabeled') && payload[:label][:name].include?('qa-approved')
          Hubstats::QaSignoff.remove_signoff(payload[:repository][:id], payload[:pull_request][:id])
        elsif payload[:label][:name].include?('qa-approved')
          Hubstats::QaSignoff.first_or_create(payload[:repository][:id], payload[:pull_request][:id], payload[:sender][:id], payload)
        end
        new_pull.update_label(payload)
      else
        repo_name = Hubstats::Repo.where(id: new_pull.repo_id).first.full_name
        labels = Hubstats::GithubAPI.get_labels_for_pull(repo_name, new_pull.number)
        new_pull.add_labels(labels)
      end
      new_pull.save!
    end

    # Public - Gets the information for the new comment and updates it
    #
    # payload - the information that we will use to get data off of
    #
    # Returns - nothing, but updates the comment
    def comment_processor(payload, kind)
      comment = payload[:comment]
      comment[:kind] = kind
      comment[:repo_id] = payload[:repository][:id]
      comment[:pull_number] = get_pull_number(payload)
      Hubstats::Comment.create_or_update(comment.with_indifferent_access)
    end

    # Public - Gets the information for the new team and updates it
    #
    # payload - the information that we will use to get the data off of
    #
    # Returns - nothing, but updates or makes the team
    def team_processor(payload)
      team = payload[:team]
      team_list = Hubstats.config.github_config["team_list"] || []
      if team_list.include? team[:name]
        Hubstats::Team.create_or_update(team.with_indifferent_access)
        hubstats_team = Hubstats::Team.where(name: team[:name]).first
        hubstats_user = Hubstats::User.create_or_update(payload[:member])
        Hubstats::Team.update_users_in_team(hubstats_team, hubstats_user, payload[:github_action])
      end
    end

    # Public - Grabs the PR number off of any of the various places it can be
    #
    # payload - the thing that we will use to try to attain the PR number
    #
    # Returns - the PR number
    def get_pull_number(payload)
      if payload[:pull_request]
        return payload[:pull_request][:number]
      elsif payload[:issue]
        return payload[:issue][:number]
      elsif payload[:comment][:pull_request_url]
        return payload[:comment][:pull_request_url].split('/')[-1]
      else
        return nil
      end
    end
  end
end
