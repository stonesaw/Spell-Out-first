class EnemyData
  attr_accessor :name, :spell, :hp, :max_hp, :score, :var
  attr_reader :stage_hash, :image, :anime
  
  def initialize(name, spell, hp, score, image, anime: [])
    @name = name.to_sym
    @spell = spell.to_sym
    @hp = hp.to_i
    @max_hp = @hp
    @score = score.to_i
    @image = image
    @anime = anime
    @var = {}
    @stage_hash = { any: Proc.new{} }
  end
  
  # plz block
  def stage_is(stage = :amy, &block)
    stage = stage.to_sym
    @stage_hash[stage] = block
  end 
end


class Enemy < Sprite
  attr_reader :data, :spawn_tick
  attr_accessor :hp_bar, :hp_bar_base
    
  def initialize(data, now_tick, x, y)
    @data = data.dup
    super
    self.x = x
    self.y = y
    self.image = @data.image
    @anime = @data.anime
    @_anime_cnt = 0
    # @data.remove_instance_variable(:@image)
    # @data.remove_instance_variable(:@anime)
    @spawn_tick = now_tick
    
    Enemies.list << self
    self
  end

  def _anime_next
    @_anime_cnt = (@_anime_cnt + 1) % @anime.length
    @image = @anime[@_anime_cnt]
    self.image = @image
  end

  def add_hp_bar(x: 1, y: 1)
    UI.enemy_hp_bar << {
      enemy: self, 
      base: Image.new(x * (self.image.width * 0.9),    y * (self.image.height * 0.15), [240, 240, 240]),
      bar: Image.new(x * (self.image.width * 0.9 - 4), y * (self.image.height * 0.15 - 4), [124, 224, 43])
    }
  end


  def add_boss_bar()
    UI.boss_hp_bar << {
      enemy: self, 
      base: Image.new(self.image.width * 0.9, self.image.height * 0.15, [240, 240, 240]),
      bar: Image.new(self.image.width * 0.9 - 4, self.image.height * 0.15 - 4, [124, 224, 43])
    }
  end
end
