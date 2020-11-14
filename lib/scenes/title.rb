# Scene - Titlee
# draw the scene & jump any scene

class Title < Scene
  def initialize
    Debugger.color = C_RED
    @@font_title = Font.new(300, "Poco")
    @@font = Font.new(160, "Poco")
    @@bgm = Sound.new("#{$PATH}/assets/sound/38-5.wav") # 62.118 sec
    @@se_enter_play = Sound.new("#{$PATH}/assets/sound/se_retro03.wav")
    @@se_cursor = Sound.new("#{$PATH}/assets/sound/se_system27.wav")
    play   = @@font.get_width("PLAY")
    credit = @@font.get_width("CREDIT")
    exit_  = @@font.get_width("EXIT")
    @@section_play   = Sprite.new(900, 500, Image.new(play+10,   90, C_CYAN))
    @@section_credit = Sprite.new(850, 600, Image.new(credit+10, 90, C_CYAN))
    @@section_exit   = Sprite.new(800, 700, Image.new(exit_+10,  90, C_CYAN))
    @@cursor = -99
    @@s_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @@blank = 60
    
    @@tick = 0
    @@mini_char = Sprite.new(60, Window.height - 100 - $player_images[0][0].height, $player_images[0][0])
    @@mini_char_anime = 0
    @@mini_field_top = Sprite.new(0, Window.height - 102, Image.new(Window.width, 22, [140, 255, 255, 255]))
    @@mini_field_img = Image.new(48, 80, [100, 255, 255, 255])
    @@spell_count = 0
    @@hit_spell = nil
    Bullet.reset
  end

  class << self
    def set_music
      @@bgm.set_volume(200)
      @@se_cursor.set_volume(224)
      @@bgm.play
      @@bgm.set_volume(226, 1000)
    end

    def update
      @@tick += 1
      # bgm loop
      bgm_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      diff = (bgm_end - @@s_time).floor(1)
      if @@blank <= 0 && diff % 61.5 == 0 # ずれが0.6秒くらい？
        @@bgm.play
        @@blank = 60
      end
      @@blank = [0, @@blank - 1].max
      
      # cursor
      @@se_cursor.play if Input.key_push?(K_DOWN) || Input.key_push?(K_UP)
      @@cursor += 1 if Input.key_push?(K_DOWN)
      @@cursor -= 1 if Input.key_push?(K_UP)
      @@cursor = [[0, @@cursor].max, 2].min if @@cursor != -99
      @@cursor = -99 if @@section_play.on_mouse? || @@section_credit.on_mouse? || @@section_exit.on_mouse?

      if Input.mouse_down?(0) || Input.key_down?(K_RETURN)
        if @@section_play.on_mouse? || @@cursor == 0
          @@se_enter_play.play
          SceneManager.next(:play, loading: true)
          return
        end
        if @@section_credit.on_mouse? || @@cursor == 1
          SceneManager.next(:play, loading: true) 
          return
        end
        Window.close if @@section_exit.on_mouse? || @@cursor == 2
      end

      # mini charactor
      if @@tick % 10 == 0
        @@mini_char_anime = (@@mini_char_anime + 1) % 3 
        @@mini_char.image = $player_images[0][@@mini_char_anime]
      end

      if Input.key_push?(K_SPACE) || Input.mouse_push?(0)
        x = @@mini_char.x + @@mini_char.image.width * 0.7
        y = @@mini_char.y + @@mini_char.image.height * 0.6
        spell = $spell_color.keys[@@spell_count]
        img = Image.new(10, 10, $spell_color.values[@@spell_count])
        Bullet.new(spell, 0, 0, x, y, img)
        @@spell_count = (@@spell_count + 1) % 5
      end
      Bullet.all.each do |b|
        if b.x >= Window.width - 10
          @@hit_spell = b.spell
        end
      end
      Bullet.update
    end

    def draw
      c = @@hit_spell ? $spell_color[@@hit_spell] : C_WHITE
      Window.draw_font(30, -100, "Spell", @@font_title, color: c)
      Window.draw_font(30, 100, "Out", @@font_title, color: c)

      # @@section_play.draw
      # @@section_credit.draw
      # @@section_exit.draw

      _draw_section

      @@mini_char.draw
      _draw_mini_char_field
    end

    def last
      @@bgm.stop
      @@bgm.dispose
    end

    def _draw_section
      # play
      if @@section_play.on_mouse? || @@cursor == 0
        Window.draw_font(@@section_play.x + 10, @@section_play.y - 60, "PLAY", @@font)
        Window.draw_line(@@section_play.x,               @@section_play.y + @@section_play.image.height,
          @@section_play.x + @@section_play.image.width, @@section_play.y + @@section_play.image.height, C_WHITE
        )
      else
        Window.draw_font(@@section_play.x + 10, @@section_play.y - 60, "PLAY", @@font, color: [200, 255, 255, 255])
      end

      # credit
      if @@section_credit.on_mouse? || @@cursor == 1
        Window.draw_font(@@section_credit.x + 10, @@section_credit.y - 60, "CREDIT", @@font)
        Window.draw_line(@@section_credit.x,               @@section_credit.y + @@section_credit.image.height,
          @@section_credit.x + @@section_credit.image.width, @@section_credit.y + @@section_credit.image.height, C_WHITE
        )
      else
        Window.draw_font(@@section_credit.x + 10, @@section_credit.y - 60, "CREDIT", @@font, color: [200, 255, 255, 255])
      end

      # exit
      if @@section_exit.on_mouse? || @@cursor == 2
        Window.draw_font(@@section_exit.x + 10, @@section_exit.y - 60, "EXIT", @@font)
        Window.draw_line(@@section_exit.x,               @@section_exit.y + @@section_exit.image.height,
          @@section_exit.x + @@section_exit.image.width, @@section_exit.y + @@section_exit.image.height, C_WHITE
        )
      else
        Window.draw_font(@@section_exit.x + 10, @@section_exit.y - 60, "EXIT", @@font, color: [200, 255, 255, 255])
      end
    end

    def _draw_mini_char_field
      @@mini_field_top.draw
      Bullet.draw

      base_y = @@mini_char.y + @@mini_char.image.height + 20
      17.times do |i|
        x = i*80 - @@tick % 80
        w = @@mini_field_img.width
        h = @@mini_field_img.height
        Window.draw_morph(x+30, base_y, x, base_y+h, x+w, base_y+h, x+w+30, base_y, @@mini_field_img)
      end
    end
  end
end
