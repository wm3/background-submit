require 'rspec'
require 'capybara/rspec'
require 'akephalos'
require 'yaml'
require_relative 'helpers/mock_server'
require_relative 'helpers/data'


###
# Configurations
###

#Capybara.javascript_driver = :akephalos

Capybara.app = MockServer.new




###
# Specs
###

describe 'SubmitMultipart', :type => 'request', :js => true do

  let(:server) { MockServer }
  let(:server_listener) do
    server_listener = double('server_listener')
    server.listener = server_listener
  end

  before do
    server.listener = nil
  end



  let(:main_script) do
    <<-EOS
      #{ open('js/background-submit.js', &:read) };

      var multipart;
      window.addEventListener('load', function() {
        var form = document.querySelector('form');
        multipart = SubmitMultipart.activate(form);
      });
    EOS
  end

  let(:main_form) do
    <<-EOS
      <form action='submit' method='post' enctype='multipart/form-data'>
        #{inputs}
        <input type='submit' value='OK'>
      </form>
    EOS
  end

  let(:inputs) { '' }

  before do
    server.body = '<h1>previous page</h1>'
    visit '/?previous';

    server.script = main_script
    server.body = '<h1>main page</h1>' + main_form
    visit '/'
  end


  read_yaml('form_submission.yaml').each do |condition_name, info|

    describe "with a form that #{condition_name}" do
      let(:inputs) { info['inputs'] }
      let(:form_values) { info['values'] }

      it 'should submit the specified values' do
        server_listener.should_receive(:submit).with form_values

        page.execute_script('multipart.submit()');
      end
    end

  end


  describe 'with a file input field' do
    let(:inputs) { '<input id="file_input" type="file" name="file_input">' }

    it 'should send a file as a multipart data if specified' do
      @params = nil
      server_listener.stub(:submit) {|p| @params = p }

      attach_file('file_input', data_file('attachment.txt'))
      page.execute_script('multipart.submit()')
      find('form')

      @params.should include('file_input')
      @params['file_input'].should be_multipart_data(read_file('attachment.txt'))
    end

  end


  # TODO cannot pass when akephalos is used
  it 'should keep history state' do
    page.execute_script('multipart.submit()');
    find('h1').should have_content('main page')

    page.execute_script('window.history.back()')
    find('h1').should have_content('previous page')
  end


  ###
  # Helpers
  ###

  def multipart_data?(data, actual)
    actual.should include :tempfile
    open(actual[:tempfile], &:read).should eq data
  end

  matcher :be_multipart_data do |data|
    match {|actual| multipart_data?(data, actual)}
  end

end
# vim: set shiftwidth=2 expandtab :
