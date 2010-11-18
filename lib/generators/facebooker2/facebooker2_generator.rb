class Facebooker2Generator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  argument :application_type, :type => :string, :default => 'regular'

  def generate_facebooker2
    template  'facebooker.yml', 'config/facebooker.yml'
    copy_file 'initializer.rb', 'config/initializers/facebooker2.rb'

    include = application_type == 'regular' ? 'Facebooker2::Rails::Controller' : 'Facebooker2::Rails::Controller::CanvasOAuth'
    puts <<-MSG
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      Add the following line to your app/controllers/application_controller.rb:

      include #{include}

      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    MSG
  end
end
