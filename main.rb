require 'selenium-webdriver'
require 'win32/sound'
require 'timeout'
include Win32

# ---------------------------CONFIGURATION------------------------------------------

BROWSER_PATH = 'C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe'
TARGET_URL = 'https://gp-explorer.fr/billetterie/revente/'
CHECK_TEXT = 'Aucun billet disponible pour le moment, veuillez essayer plus tard.'

# --- AJUSTER LES CYCLE CHECKS EN FONCTION DU NOMBRE DE GENS DANS LA QUEUE ---
CYCLE_CHECKS = 20
# --- AJUSTER LES CYCLE CHECKS EN FONCTION DU NOMBRE DE GENS DANS LA QUEUE ---

REFRESH_DELAY = 2
TIMEOUT_SECONDS = 15

# ---------------------------CONFIGURATION-------------------------------------------

def find_and_switch_to_weezevent_iframe(driver)
  iframe_selectors = [
    "//iframe[contains(@src, 'weezevent')]",
    "//iframe[contains(@src, 'widget')]",
    "//iframe[contains(@id, 'weezevent')]",
    "//iframe[contains(@class, 'weezevent')]",
    "//iframe"
  ]
  
  iframe_selectors.each do |selector|
    begin
      if selector == "//iframe"
        iframes = driver.find_elements(:xpath, selector)
        iframes.each do |iframe|
          begin
            src = iframe.attribute('src') || ''
            if src.include?('weezevent') || src.include?('widget') || src.empty?
              driver.switch_to.frame(iframe)
              return true
            end
          rescue
            next
          end
        end
      else
        iframe = driver.find_element(:xpath, selector)
        driver.switch_to.frame(iframe)
        return true
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
      next
    rescue => e
      driver.switch_to.default_content
    end
  end
  
  return false
end

def accept_cookies(driver)
  begin
    sleep 2
    buttons = driver.find_elements(:xpath, "//button | //input[@type='button'] | //a")
    btn = buttons.find { |b| b.displayed? && b.text =~ /(Accepter tout|Tout accepter|J'accepte|Accepter les cookies)/i }
    btn.click if btn
  rescue
  end
end

def scroll_to_position(driver)
  begin
    driver.execute_script("window.scrollTo({ top: 2100, behavior: 'smooth' });")
    sleep 0.5
  rescue
  end
end

def play_alert
  4.times do
    Sound.play('SystemExclamation')
    sleep 0.5
  end
end

def check_billets(driver)
  message_detected = false
  
  scroll_to_position(driver)
  sleep 1
  
  CYCLE_CHECKS.times do |i|
    main_body_text = ""
    begin
      driver.switch_to.default_content
      main_body_text = driver.find_element(:tag_name, 'body').text
    rescue
    end

    iframe_body_text = ""
    iframe_found = find_and_switch_to_weezevent_iframe(driver)
    
    if iframe_found
      begin
        iframe_body_text = driver.find_element(:tag_name, 'body').text
      rescue
      ensure
        driver.switch_to.default_content
      end
    end

    all_text = "#{main_body_text} #{iframe_body_text}"
    normalized_check = CHECK_TEXT.gsub(/\s+/, ' ').strip.downcase
    normalized_all = all_text.gsub(/\s+/, ' ').strip.downcase
    
    if iframe_body_text.include?(CHECK_TEXT) || 
       main_body_text.include?(CHECK_TEXT) || 
       normalized_all.include?(normalized_check) || 
       normalized_all.include?("aucun billet disponible")
      
      message_detected = true
      puts "[#{Time.now.strftime('%H:%M:%S')}] Message detecte a la verification #{i + 1}/#{CYCLE_CHECKS}"
      puts "[#{Time.now.strftime('%H:%M:%S')}] Attente #{REFRESH_DELAY}s avant refresh..."
      sleep REFRESH_DELAY
      return message_detected
    else
      puts "[#{Time.now.strftime('%H:%M:%S')}] Verification #{i + 1}/#{CYCLE_CHECKS}"
    end

    sleep 1
  end
  
  return message_detected
end

begin
  system("cls") || system("clear")
  
  options = Selenium::WebDriver::Chrome::Options.new
  options.binary = BROWSER_PATH
  options.add_argument('--start-maximized')
  options.add_argument('--disable-web-security')
  options.add_argument('--disable-features=VizDisplayCompositor')
  
  driver = Selenium::WebDriver.for :chrome, options: options

  puts "[#{Time.now.strftime('%H:%M:%S')}] Ouverture de la page de revente..."
  driver.navigate.to TARGET_URL
  sleep 2

  accept_cookies(driver)
  
  iframe_detected = false
  detection_attempts = 0
  
  while !iframe_detected && detection_attempts < 10
    detection_attempts += 1
    
    if find_and_switch_to_weezevent_iframe(driver)
      puts "[#{Time.now.strftime('%H:%M:%S')}] Iframe Weezevent detectee !"
      driver.switch_to.default_content
      iframe_detected = true
    else
      puts "[#{Time.now.strftime('%H:%M:%S')}] Iframe non detectee - Refresh et nouvel essai..."
      driver.navigate.refresh
      sleep 2
      accept_cookies(driver)
      sleep 2
    end
  end
  
  if !iframe_detected
    puts "[#{Time.now.strftime('%H:%M:%S')}] ERREUR : Iframe Weezevent non detectee après 10 tentatives"
    puts "[#{Time.now.strftime('%H:%M:%S')}] Le script ne peut pas fonctionner sans iframe"
    exit
  end

  cycle_count = 0
  loop do
    cycle_count += 1
    puts "\n[#{Time.now.strftime('%H:%M:%S')}] === CYCLE #{cycle_count} ==="
    
    message_detected = check_billets(driver)

    if message_detected
      puts "[#{Time.now.strftime('%H:%M:%S')}] Rafraichissement de la page..."
      driver.navigate.refresh
      sleep 2
      accept_cookies(driver)
      puts "[#{Time.now.strftime('%H:%M:%S')}] Pause 2s avant nouveau cycle..."
      sleep 2
    else
      puts "\n[#{Time.now.strftime('%H:%M:%S')}] Billets probablement disponibles !"
      play_alert
      
      loop { sleep 60 }
    end
  end
  
rescue Interrupt
  puts "\nArret manuel - Fermeture..."
  driver.quit if driver
rescue => e
  puts "\nErreur fatale : #{e.message}"
  driver.quit if driver
ensure
  begin
    driver.quit if driver
  rescue
  end
end