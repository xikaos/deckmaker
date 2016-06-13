#Dependencies
require 'nokogiri'
require 'httparty'
require 'bigdecimal'
require 'bigdecimal/util'

#Constant defining the base URL used in requests
QUERY_STRINGS = {
  menor_preco: "&orderBy=7",
}

BASE_URL = "http://www.ligamagic.com.br/?view=cards%2Fsearch&card=current_card"
LANDS = {
  plains: {
    name: "Plains",
    price: "0.25".to_d
  }
}


PROVIDERS = {
  cards_of_paradise: ""
}

def setup
  @deck = Array.new
  @providers = Array.new
  @cost = 0
end

#Helper method to abstract Nokogiri/HTTParty method calls
def do_request url
  Nokogiri::HTML(HTTParty.get(url))
end

#Helper for filtering the table row by the provider string passed to the method
def filter_by_provider row, provider
  row.css("td > a > img").attr("title").text == provider.to_s
end

#Helper for removing undesired characters in the .txt input
def clear_lines lines
  lines = lines.map do |line|
    line = line.gsub(/(\n)$/, "")
    line = line.gsub(/(\t)/,"")
    next if line == "\n"
  end
end

#Get the data from the input line and return a hash for structured access to 
#"pure" card information
def extract_data line
  card_num = line.match(/^\d+/).to_s
  card_name = line.gsub(/^\d+/,"").strip
  require 'pry'; binding.pry;
    if card_has = line.match(/\[(\d+)\]/)
      card_has = card_has.captures.first
      card_name = card_name.gsub(/\[\d+\]/,"").strip
    else
      card_has = 0
    end
    card = {
      card_name: card_name,
      card_num: card_num.to_i,
      card_has: card_has.to_i,
    }
end

#Based on a clear input from clear_lines, we now instantiate our cards objects using
# extract_data as a helper for this task
def instantiate_cards clean_lines
  clean_lines.map do |line|
    already_there = false
    require 'pry'; binding.pry;
    tmp_card = extract_data(line)
    name = tmp_card[:card_name]
    num = tmp_card[:card_num]
    has = tmp_card[:card_has]
    Card.new(name, num, has)
  end
end

def parse file
  File.open(file.to_s) {|f| f.select {|line| line != "\n" } }
end


class Card
  attr_accessor :self, :price, :cost, :has

  def initialize(name, num, has=0)
    @self = {
      name: name,
      num: num,
      has: has, }
  end

  def name
    @self[:name]
  end

  def num
    @self[:num]
  endq

  def has
    @self[:has]
  end

  def param 
    @self[:name].gsub(' ', '+')
  end
end


def main
lines = clear_lines(parse(ARGV[0]))
@deck = instantiate_cards(lines)

@deck.each do |card|
  provider = "ARGV[1]"
  doc = do_request(BASE_URL.gsub("current_card",card.param))
  provider_row = nil
  found = false
  match = (/\d*\,+\d*/)
  doc.children.css("#cotacao-1 > tbody > tr:nth-child(n)").each do |row|
    #provider_row = row if filter_by_provider(row, provider)
    @providers = Array.new
    require 'pry'; binding.pry;
    puts ''
  end
  unless provider_row
    puts "O fornecedor #{provider} não tem em estoque a carta #{card.name}"
    next
  end
  card.price = provider_row.text.match(match).to_s.gsub(",",".").to_d
  card.cost = card.price * (card.num - card.has)
  @cost += card.cost
end


end



puts @cost
end
require 'pry'; binding.pry;
puts "foi"




