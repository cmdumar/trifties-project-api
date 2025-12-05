namespace :admin do
  desc "Make a user an admin"
  task :promote, [:email] => :environment do |_t, args|
    email = args[:email]
    
    if email.blank?
      puts "Usage: rails admin:promote[user@example.com]"
      exit
    end
    
    user = User.find_by(email: email)
    
    if user.nil?
      puts "User with email #{email} not found."
      exit
    end
    
    if user.admin?
      puts "User #{email} is already an admin."
    else
      user.update(admin: true)
      puts "User #{email} has been promoted to admin."
    end
  end

  desc "Remove admin status from a user"
  task :demote, [:email] => :environment do |_t, args|
    email = args[:email]
    
    if email.blank?
      puts "Usage: rails admin:demote[user@example.com]"
      exit
    end
    
    user = User.find_by(email: email)
    
    if user.nil?
      puts "User with email #{email} not found."
      exit
    end
    
    if user.admin?
      user.update(admin: false)
      puts "Admin status removed from #{email}."
    else
      puts "User #{email} is not an admin."
    end
  end

  desc "List all admins"
  task list: :environment do
    admins = User.where(admin: true)
    
    if admins.empty?
      puts "No admins found."
    else
      puts "Admins:"
      admins.each do |admin|
        puts "  - #{admin.email} (ID: #{admin.id})"
      end
    end
  end
end

