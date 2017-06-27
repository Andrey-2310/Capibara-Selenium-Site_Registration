require 'json'
require 'open-uri'
require 'capybara'
require 'capybara/dsl'
require 'capybara/session'
require 'selenium-webdriver'
require 'securerandom'
#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

dev_by= 'https://dev.by/registration'
session= Capybara::Session.new(:selenium)

ARGV[0].to_i.times do
  while true do
    username=SecureRandom.hex(4)
    password=SecureRandom.urlsafe_base64(8, false)

    parsed_data = JSON.parse((open("https://post-shift.ru/api.php?action=new&type=json")).string)
    if parsed_data['key']==nil
      break
    end

    email=parsed_data['email']
    key=parsed_data['key']

    session.visit(dev_by)

    session.fill_in('user[username]', :with => username)
    session.fill_in('user[email]', :with => email)

    session.fill_in('user[password]', :with => password)
    session.fill_in('user[password_confirmation]', :with => password)

    session.check('user_agreement')
    session.find('input.btn[type="submit"]').click

    response=JSON.parse((open("https://post-shift.ru/api.php?action=getmail&type=json&key=#{key}&id=1")).string)
    redo if response['message'] == nil
    link=response['message'].split('<')[1].chop.split('=')
    link[1].slice!(0..1)
    session.visit link.join('=')

    if session.first('.block-alerts') == nil #Registration failed
      parsed_data=JSON.parse((open("https://post-shift.ru/api.php?action=delete&type=json&key=#{key}")).string)
      print parsed_data['delete']

      break
    end
    puts  email +'     '+ password
    parsed_data=JSON.parse((open("https://post-shift.ru/api.php?action=delete&type=json&key=#{key}")).string)
    break
  end
end


