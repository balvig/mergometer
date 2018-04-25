require "progress_bar"
require "mergometer/pull_request"

module Mergometer
  class Report
    require "hirb"

    def initialize(repo, **options)
      @repo = repo
      @from = options[:from] || (Date.today - 1.day).beginning_of_week.to_s
    end

    def run
      preload
      render
    end

    private

      attr_accessor :repo, :from

      def render
        puts Hirb::Helpers::AutoTable.render(
          sorted_entries,
          unicode: true,
          fields: fields,
          description: false
        )

        puts "Total number of PRs checked: #{prs.size} (#{filter})"
      end

      def fields
        raise "Implement fields method"
      end

      def sort_field
        fields.last
      end

      def sorted_entries
        entries.sort_by(&sort_field).reverse
      end

      def entries
        prs
      end

      def filter
        "base:master #{repo} type:pr is:merged created:>=#{from}"
      end

      def fields_to_preload
        []
      end

      def prs
        @_prs ||= fetch_prs
      end

      def fetch_prs
        Array(filter).flat_map do |filter|
          PullRequest.search(filter)
        end
      end

      def preload
        prs.each do |pr|
          fields_to_preload.each do |field|
            pr.send(field)
          end
          progress_bar.increment!
        end
      end

      def progress_bar
        @_progress_bar ||= ProgressBar.new(prs.size, :bar, :counter, :elapsed)
      end
  end
end
