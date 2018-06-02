# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  invisible_captcha only: [:create], honeypot: :subtitle, scope: :user
end
