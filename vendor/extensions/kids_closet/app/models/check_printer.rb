class CheckPrinter < ActiveRecord::BaseWithoutTable
  column :owner_name, :string, ""
  column :company_name, :string, ""
  column :address, :string, ""
  column :address_2, :string, ""
  column :routing_number, :string, ""
  column :account_number, :string, ""
  column :transit_number, :string, ""
  column :starting_check_number, :integer, ""
  column :bank_name, :string, ""
  
  validates_presence_of :owner_name, :bank_name, :address, :address_2, :routing_number, :account_number, :transit_number, :starting_check_number
  validates_numericality_of :starting_check_number, :only_integer => true, :greater_than => 100
  validates_length_of :routing_number, :is => 9, :message => "must be 9 digits long"
  def self.written_check_amount(val, include_and = false)
    end_string = " and #{((val - val.to_i) * 100).round.to_i}/100*****" 
    exp_hash = {
        3 => 'thousand',
        6 => 'million',
        9 => 'billion',
        12 => 'trillion',
        15 => 'quadrillion',
        18 => 'quintillion',
        21 => 'sexillion',
        24 => 'septillion',
        27 => 'octillion',
        30 => 'nonillion',
        33 => 'decillion',
        36 => 'undecillion',
        39 => 'duodecillion',
        42 => 'tredecillion',
        45 => 'quattuordecillion',
        48 => 'quindecillion',
        51 => 'sexdecillion',
        54 => 'septendecillion',
        57 => 'octodecillion',
        60 => 'novemdecillion',
        63 => 'vigintillion',
        66 => 'unvigintillion',
        69 => 'duovigintillion'
        }
    digits = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69]
    max_exponent = 69
    val = val.to_i.abs
    return "zero" if val == 0

    include_and = false if val <= 100

    vals = []
    while val > 0
     vals << val % 1000
     val = val / 1000
    end
    s_num = ""
    vals.each_index do |i|
      if i == 0
       s_num = self.h_Small(vals[i],include_and)
      else
       s_num = self.h_Small(vals[i],include_and) + " " + exp_hash[digits[i-1]] + " " + s_num if vals[i] != 0
      end
    end
    s_num + end_string
  end
  
  def self.h_Small(h,include_and = false)
    numbers = {
        1 => 'one',
        2 => 'two',
        3 => 'three',
        4 => 'four',
        5 => 'five',
        6 => 'six',
        7 => 'seven',
        8 => 'eight',
        9 => 'nine',
        10 => 'ten',
        11 => 'eleven',
        12 => 'twelve',
        13 => 'thirteen',
        14 => 'fourteen',
        15 => 'fifteen',
        16 => 'sixteen',
        17 => 'seventeen',
        18 => 'eighteen',
        19 => 'nineteen',
        20 => 'twenty',
        30 => 'thirty',
        40 => 'forty',
        50 => 'fifty',
        60 => 'sixty',
        70 => 'seventy',
        80 => 'eighty',
        90 => 'ninety'
        }

   return "" if h <= 0
   num1 = h % 100
   h_num = ""
   if num1 != 0
     if num1 <= 20
       h_num = numbers[num1]
     else
       h_num << numbers[(num1/10)*10]
       h_num << "-" << numbers[num1%10] if num1%10 != 0
     end
   end
   h_num2 = ""
   if h >= 100
     h_num2 = numbers[h / 100]
     if include_and
       h_num2 += " hundred "
       h_num2 += ("and " + h_num) if h_num != ""
     else
       h_num2 += " hundred "
       h_num2 += h_num if h_num != ""
     end
     h_num2
   else
     h_num
   end
  end
end
