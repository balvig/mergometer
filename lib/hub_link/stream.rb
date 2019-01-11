require "hub_link/api/pull_request"
require "hub_link/batch"

module HubLink
  class Stream
    GITHUB_BATCH_SIZE = 14

    def initialize(repos, start_date: 2.years.ago)
      @repos = repos.split(",")
      @start_date = start_date.to_date
    end

    def in_batches(&block)
      queries.each do |query|
        yield Batch.new(query)
      end
    end

    private

      attr_accessor :repos, :start_date

      def queries
        start_date.step(end_date, GITHUB_BATCH_SIZE).map do |date|
          "type:pr updated:#{date}..#{date + GITHUB_BATCH_SIZE} #{repo_query}"
        end
      end

      def end_date
        Date.tomorrow
      end

      def repo_query
        @_repo_query ||= build_repo_query
      end

      def build_repo_query
        repos.map do |r|
          "repo:#{r}"
        end.join(" ")
      end
  end
end
