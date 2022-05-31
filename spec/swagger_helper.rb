# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root   = Rails.root.join('swagger').to_s
  config.swagger_docs   = {
    'v1/swagger.yaml' => {
      openapi:    '3.0.1',
      info:       {
        title:   'API V1',
        version: 'v1'
      },
      components: {
        securitySchemes: {
          bearer: {
            type: :apiKey,
            name: 'Authorization',
            in:   :header
          }
        },
        schemas:         {
          user:                {
            type:       :object,
            properties: {
              id:         { type: :integer },
              email:      { type: :string, format: :email },
              name:       { type: :string },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' },
              role:       { type: :string, enum: %i[admin], default: :admin }
            }
          },
          credentials:         {
            type:       :object,
            properties: {
              user: {
                type:       :object,
                properties: {
                  email:    { type: :string, format: :email },
                  password: { type: :string, format: :password }
                }
              }
            }
          },
          user_email:          {
            type:       :object,
            properties: {
              user: {
                type:       :object,
                properties: {
                  email: { type: :string, format: :email }
                }
              }
            }
          },
          user_reset_password: {
            type:       :object,
            properties: {
              user: {
                type:       :object,
                properties: {
                  reset_password_token:  { type: :string, example: 'reset_password_token' },
                  password:              { type: :string, format: :password },
                  password_confirmation: { type: :string, format: :password }
                }
              }
            }
          }
        }
      },
      paths:      {},
      servers:    [
        {
          url:       'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ]
    }
  }
  config.swagger_format = :yaml
end
