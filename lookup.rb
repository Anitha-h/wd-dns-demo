def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument

dns_raw = File.readlines("zone")

def parse_dns(raw)
  raw.reject { |line| line.empty? || line[0].chr == "#" }.
    map { |line| line.strip.split(", ") }.
    each_with_object({}) do |record, records|
    # Modify the `records` hash so that it contains necessary details.
    inner_hash = Hash.new
    inner_hash["type"] = record[0]
    inner_hash["target"] = record[2]
    records[record[1]] = inner_hash
  end
end

def resolve(dns_records, lookup_chain, domain)
  record = dns_records[domain]

  if (!record)
    lookup_chain << "Error: record not found for " + "#{ARGV[0]}"
  elsif record["type"] == "CNAME"
    lookup_chain << record["target"]
    resolve(dns_records, lookup_chain, record["target"])
  elsif record["type"] == "A"
    lookup_chain << record["target"]
  else
    lookup_chain << "Error: record not found for " + "#{ARGV[0]}"
  end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
