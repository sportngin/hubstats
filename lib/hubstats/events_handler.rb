module Hubstats
  class EventsHandler

    def route(payload, type) 
      case type
      when "issue_comment", "IssueCommentEvent"
        comment_processor(payload,"Issue")
      when "commit_comment", "CommitCommentEvent"
        comment_processor(payload,"Commit")
      when "pull_request", "PullRequestEvent"
        pull_processor(payload)
      when "pull_request_review_comment", "PullRequestReviewCommentEvent"
        comment_processor(payload,"PullRequest")
      end
    end

    def pull_processor(payload)
      pull_request = payload[:pull_request]
      pull_request[:repository] = payload[:repository]
      new_pull = Hubstats::PullRequest.create_or_update(pull_request.with_indifferent_access)
      repo_name = Hubstats::Repo.where(id: new_pull.repo_id).first.full_name
      labels = Hubstats::GithubAPI.get_labels(repo_name, new_pull.number )
      new_pull.add_labels(labels)
    end

    def comment_processor(payload,kind)
      comment = payload[:comment]
      comment[:kind] = kind
      comment[:repo_id] = payload[:repository][:id]
      comment[:pull_number] = get_pull_number(payload)

      comment = Hubstats::Comment.create_or_update(comment.with_indifferent_access)
      update_labels_from_comment(payload) if (kind == "Issue")
      comment
    end

    #grabs the number off of anyone of the various places it can be
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

    def update_labels_from_comment(payload)
      repo_id = payload[:repository][:id]
      number = payload[:issue][:number]
      labels = payload[:issue][:labels]
      pull = Hubstats::PullRequest.belonging_to_repo(repo_id).where(number: number).first
      pull.add_labels(labels)
    end
    
  end
end
