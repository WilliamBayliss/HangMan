require "yaml"

module HangMan
  class Game
    def initialize
      @secret_word = get_word()
      create_blank()
      @failed_attempts = 0
      @guessed_letters = []

      
      initial_input()

      play_game()
    end

    def play_game
      until @blank == @secret_word
        round()
      end
    end

    def round
      puts @blank
      puts "Failed guesses: " + @guessed_letters.join(" ")
      puts "You have #{ 6 - @failed_attempts} guesses left!"
      player_guess = get_user_input()
      update_blank(player_guess)
      check_win_condition()
      hang_the_man()
      save_game()
    end

    def initial_input
      puts "Would you like to load an existing game? Please enter 'yes' or 'no'"
      answer = gets.chomp.downcase
      if answer == "yes"
        load_game()
      else
        return
      end
    end

    def create_blank
      ##Creates a string of "_" the length of @secret_word
      @blank = @secret_word.gsub(/./, "_")
    end

    def get_user_input
      ##Gets user input
      user_input = gets.chomp.downcase
      ##when user input longer than 1 character, print error message and re-run function
      if user_input.length > 1
        puts "Please guess one letter at a time."
        get_user_input()
      else 
        return user_input
      end
    end

    def check_matches(correct_guess_count, user_input)
      if correct_guess_count == 0
        @failed_attempts += 1
        if @guessed_letters.include?(user_input)
          return
        else
          @guessed_letters.append(user_input)
        end
      end
    end

    

    def update_blank(user_input)
      word_array = @secret_word.split("")
      blank_array = @blank.split("")
      correct_guess_count = 0

      word_array.each_with_index { |letter, index|
        blank_array.each_with_index { |underscore, b_index|
          if b_index == index && letter == user_input
            underscore.gsub!("_", user_input)
            correct_guess_count += 1
          end
        }
      }
      check_matches(correct_guess_count, user_input)
      @blank =blank_array.join()

    end

    def save_game
      File.open("save_game.txt", "w") do |game_file|
        game_file.write(YAML::dump(self))
      end
    end

    def load_game
      if File.exist?("save_game.txt")
        game = YAML::load(File.read("save_game.txt"))
        puts "Game loaded!"
        game.play_game
      else
        puts "There is no saved game!"
      end
      exit
    end

    def get_word
      dictionary = []  
      File.readlines("5desk.txt").each { |word| 
        word.strip!
        if word.length > 4 && word.length < 13
            dictionary.push(word)
        end
      }
      return dictionary[rand(0...dictionary.length)].downcase
    end

    def check_win_condition
      if @blank == @secret_word
        puts "You've guessed the word!"
      end
    end

    def hang_the_man
      hanged_man_array = ["
        +---+
        |   |
            |
            |
            |
            |
      =========
      ", "
        +---+
        |   |
        O   |
            |
            |
            |
      =========", "
        +---+
        |   |
        O   |
        |   |
            |
            |
      =========", "
        +---+
        |   |
        O   |
       /|   |
            |
            |
      =========", "
        +---+
        |   |
        O   |
       /|\\  |
            |
            |
      =========", "
        +---+
        |   |
        O   |
       /|\\  |
       /    |
            |
      =========", "
        +---+
        |   |
        O   |
       /|\\  |
       / \\  |
            |
      ========="]

      case @failed_attempts
      when 0
        puts hanged_man_array[0]
      when 1
        puts hanged_man_array[1]
      when 2
        puts hanged_man_array[2]
      when 3
        puts hanged_man_array[3]
      when 4
        puts hanged_man_array[4]
      when 5
        puts hanged_man_array[5]
      when 6
        puts hanged_man_array[6]
        puts "You've hanged the man! You lose!"
        puts "The secret word was #{@secret_word}"
        exit()
      end
    end

  end
  game = Game.new
end