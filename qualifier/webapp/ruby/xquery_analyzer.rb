require 'json'

class QueryAnalyzer
  def initialize(filepath)
    @filepath = filepath
  end

  def analyze
    File.readlines(@filepath)
      .map { |line|
        begin
          JSON.parse(line.chomp, symbolize_names: true)
        rescue JSON::ParserError => err
          $stderr.puts err
          nil
        end
      }
      .compact
      .inject({}) { |memo, line|
        memo[line[:file]] ||= { file: line[:file], sql: line[:sql], durations: [] }
        memo[line[:file]][:durations] << line[:duration]
        memo
      }
      .map { |_, line|
        line.merge(aggregate(line[:durations]))
      }
  end

  def aggregate(durations)
    count = durations.size
    sum = durations.reduce(&:+)
    {
      count: count,
      sum: sum,
      average: sum / count,
      max: durations.max,
      min: durations.min,
    }
  end

  def report
    analyze.map do |line|
      puts <<~"EOS"
        ----------------
        SQL: #{line[:sql]}
        line: #{line[:file]}

        sum: #{format(line[:sum])}
        count: #{line[:count]}
        ave #{format(line[:average])}
        max: #{format(line[:max])}
        min: #{format(line[:min])}
      EOS
    end
  end

  def format(ms)
    "#{(ms * 1000).round(2)}ms"
  end
end

QueryAnalyzer.new(ARGV[0]).report
