OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '283921014541-5av2m7btqn6au830qrjostaks735bck5.apps.googleusercontent.com', 'z1V9RcctGSMQ766GlEWw9xlI', {client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}}
end