#!/usr/bin/env ruby

require "json"
require "pry"

def approval_status1(p)
  return :draft if p["draft"] == true

  if p["approvals"] >= 2
    if p["checks"] == "success"
      return :ready
    else
      return :approved
    end
  else
    if p["user"] == "carlosefonseca"
      if p["approvals"] == 1
        return :mine_needs_1_review
      else
        return :mine_needs_reviews
      end
    else
      case p["carlosefonseca"]
      when "APPROVED"
        return :needs_another_review
      when nil
        return :needs_my_review
      else
        return :do_not_approve
      end
    end
  end
end

Dir.chdir File.expand_path "~/Developer/agent-mobile-ios"

if false
  txt = %q(
  [
    {
      "url": "https://github.com/Talkdesk/agent-mobile-ios/pull/964",
      "title": "[iOS-608] Implement the Analytics events for the \"More Options\" screen",
      "user": "marianamend3s",
      "number": 964,
      "branch": "analytics-more-options",
      "state": "open",
      "checks": "cancelled",
      "reviews": null,
      "draft": true
    },
    {
      "url": "https://github.com/Talkdesk/agent-mobile-ios/pull/963",
      "title": "[iOS-606] Implement the Analytics events for the After Call Work screen",
      "user": "marianamend3s",
      "number": 963,
      "branch": "analytics-after-call-work",
      "state": "open",
      "checks": "failure",
      "reviews": {
        "carlosefonseca": "APPROVED",
        "paulomendes": "APPROVED"
      }
    },
    {
      "url": "https://github.com/Talkdesk/agent-mobile-ios/pull/957",
      "title": "Support Xcode 12.5",
      "user": "carlosefonseca",
      "number": 957,
      "branch": "update-tests-for-xcode12.5",
      "state": "open",
      "checks": "failure",
      "reviews": null,
      "draft": true
    }
  ]
)

  pulls = JSON.parse(txt)
else
  pulls = JSON.parse(`gh api repos/:owner/:repo/pulls | jq '[.[]|{url:.html_url ,title, user:.user.login, number, branch:.head.ref, state, draft}]'`)

  pulls = pulls.map { |pr|
    pr["state"] = "draft" if pr["draft"]

    checks = `gh api repos/:owner/:repo/commits/#{pr["branch"]}/check-runs | jq -r ".check_runs[0].conclusion"`.strip()
    pr["checks"] = checks != "null" ? checks : nil

    reviews = JSON.parse(`gh api repos/:owner/:repo/pulls/#{pr["number"]}/reviews | jq 'map(select(.state != "COMMENTED"))|map({(.user.login): .state})|add'`)
    pr["reviews"] = reviews

    pr
  }
end

pulls = pulls.map { |pr|
  reviews = pr["reviews"]
  if reviews
    pr["approvals"] = reviews.count { |k, v| v == "APPROVED" }
    pr["carlosefonseca"] = reviews["carlosefonseca"]
  else
    pr["approvals"] = 0
    pr["carlosefonseca"] = nil
  end

  pr["carlosefosneca"] = "own" if pr["user"] == "carlosefonseca"
  pr["status"] = approval_status1(pr)
  pr
}

pulls.sort_by! { |pr| pr["user"] == "carlosefonseca" ? 0 : pr["number"] }

if ARGV[0] == "swiftbar"
  def color(pr)
    dark_mode = ENV["OS_APPEARANCE"] == "Dark"

    case pr["checks"]
    when "success"
      dark_mode ? "sfcolor=green" : "sfcolor=darkgreen"
    when "failure"
      "sfcolor=darkred"
      dark_mode ? "sfcolor=red" : "sfcolor=darkred"
    else
      "sfcolor=yellow"
    end
  end

  def checks_icon(pr)
    icon = case pr["checks"]
      when "success"
        "checkmark.square"
      when "failure"
        "xmark.square"
      when "cancelled"
        "exclamationmark.triangle"
      else
        "gearshape"
      end
    pr["user"] == "carlosefonseca" ? "#{icon}.fill" : icon
  end

  def approval_status(p)
    ci = "CI #{p["checks"]}"
    case p["status"]
    when :draft
      "Draft. #{ci}"
    when :ready
      "Ready to merge!"
    when :approved
      "Approved! #{ci}"
    when :mine_needs_reviews_and_checks_failed
      "Checks failed"
    when :mine_needs_1_review
      "Waiting for another review. #{ci}"
    when :mine_needs_reviews
      "Waiting for reviews. #{ci}"
    when :needs_another_review
      "Waiting for another review. #{ci}"
    when :needs_my_review
      "Go Review! #{ci}"
    when :do_not_approve
      "Reviewed as #{p["carlosefonseca"]}! #{ci}"
    end
  end

  def approval_status_icon(p)
    if p["user"] == "carlosefonseca"
      case p["status"]
      when :draft
        "puzzlepiece.fill"
      when :ready
        "checkmark.seal.fill"
      when :approved
        "gearshape.2.fill"
      when :mine_needs_1_review
        "person.fill"
      when :mine_needs_reviews
        "person.2.fill"
      when :needs_another_review
        "person.fill.and.arrow.left.and.arrow.right"
      when :needs_my_review
        "binoculars.fill"
      when :do_not_approve
        "exclamationmark.bubble.fill"
      end
    else
      case p["status"]
      when :draft
        "puzzlepiece"
      when :ready
        "checkmark.seal"
      when :approved
        "gearshape"
      when :mine_needs_1_review
        "person"
      when :mine_needs_reviews
        "person.2"
      when :needs_another_review
        "person.and.arrow.left.and.arrow.right"
      when :needs_my_review
        "binoculars.fill"
      when :do_not_approve
        "exclamationmark.bubble.fill"
      end
    end
  end

  dark_mode = ENV["OS_APPEARANCE"] == "Dark"

  icons_mine = pulls.select { |p| p["user"] == "carlosefonseca" }.map { |p| "[ :#{approval_status_icon(p)}: :#{checks_icon(p)}: ]" }.join(" ")
  icons_others = pulls.reject { |p| p["user"] == "carlosefonseca" }.map { |p| ":#{approval_status_icon(p)}:" }.join(" ")

  puts "#{icons_mine} #{icons_others} | symbolize=true"
  puts "---"
  pulls.each { |p|
    puts "##{p["number"]} #{p["title"]} • #{p["user"]} | #{color(p)} sfimage=#{approval_status_icon(p)}  href=#{p["url"]}"
    puts "#{approval_status(p)} | href=kmtrigger://macro=0D3D32AC-0AFC-471F-AA9B-6A10ED2C2116&value=#{p["number"]} sfimage=#{checks_icon(p)}"
    puts "---"
  }
  puts "---"
  puts "Refresh | refresh=true"
else
  puts JSON.pretty_generate pulls
end
