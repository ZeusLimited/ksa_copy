class DocsController < ApplicationController
  layout 'docs'
  layout false, only: :structure

  YAML_ROOT = Rails.root.join('app', 'views', 'docs', 'yml')

  def index
    @soap_methods = []
    Dir.glob(File.join(YAML_ROOT, '*.yml')).sort.each do |yaml_file|
      @soap_methods << YAML.load_file(yaml_file)
    end
    @soap_method_names = @soap_methods.map { |sm| sm['name'] }
  end

  def structure
    @structure = YAML.load_file(File.join(YAML_ROOT, 'structures', "#{params[:id]}.yml"))
  end
end
