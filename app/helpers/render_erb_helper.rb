module RenderErbHelper
  class ErbalT < OpenStruct
    def self.render_from_hash(t, h)
      ErbalT.new(h).render(t)
    end

    def render(template)
      ERB.new(template).result(binding)
    end
  end

  def bind_erb_file(filename, vars = {})
    template = File.new(filename).read
    ErbalT.render_from_hash(template, vars)
  end
end
