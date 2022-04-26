# Capacitive-Sensor-Reaction-Game
2-player old school arcade game that awards those with a faster reaction time

- Established a 2-player game with a 5-point system that rewarded contestants with a faster reaction time
- Programmed using an 8051-microcontroller employing Interrupt Service Routines (ISR), two 555 timers, two self-made rectangular capacitors that functioned as sensors, and a Liquid Crystal Display (LCD)
- Designed that if a high frequency was emitted on a CEM-1302 speaker, one would hit their respective sensor to increment their points displayed on the LCD but if a low frequency was emitted, points would decrement
- Added push buttons to control a cursor on the LCD to choose options on a menu screen like an old-school arcade game
- Translated sheet music to frequencies to program the CEM-1302 to emit the Windows XP Boot Sound (when the game was flashed/turned on), Mario Game Death Sound (if players chose to not play), Victory Sound Effect (if a player won), and the Halo 2 Theme Song (if a player won with a score of 5-0)
