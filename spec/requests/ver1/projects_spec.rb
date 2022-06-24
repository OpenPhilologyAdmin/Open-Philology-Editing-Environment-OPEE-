# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects', type: :request do
  path '/api/v1/projects' do
    let(:user) { create(:user, :admin, :approved) }

    post('Creates a new project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Creates a new project.'

      parameter name: :project, in: :body, schema: {
        type:       :object,
        properties: {
          name:        {
            type:        :string,
            description: 'Project name',
            example:     'Project name'
          },
          source_file: {
            type:        :string,
            format:      :byte,
            description: 'Base64 encoded file in the following format: `data:text/plain;base64,[base64 data]`. '\
                         '[Click here](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URLs) '\
                         'for more details on formatting.'
          }
        },
        required:   %w[name source_file]
      }

      before do
        allow(ImportProjectJob).to receive(:perform_now)
      end

      response '200', 'Project can be created' do
        let(:Authorization) { authorization_header_for(user) }
        let(:encoded_source_file) do
          Base64.encode64(File.read(Rails.root.join('spec/fixtures/sample_project.txt')))
        end
        let(:source_file) { "data:text/plain;base64,#{encoded_source_file}" }
        let(:project) do
          {
            project:
                     {
                       name:        Faker::Lorem.word,
                       source_file:
                     }
          }
        end

        schema '$ref' => '#/components/schemas/project'

        run_test!

        it 'queues importing project data' do
          expect(ImportProjectJob).to have_received(:perform_now)
        end
      end

      response '422', 'Project data invalid' do
        let(:Authorization) { authorization_header_for(user) }
        let(:project) do
          {
            project:
                     {
                       name:        nil,
                       source_file: nil
                     }
          }
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!

        it 'does not queue importing project data' do
          expect(ImportProjectJob).not_to have_received(:perform_now)
        end
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }
        let(:project) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!

        it 'does not queue importing project data' do
          expect(ImportProjectJob).not_to have_received(:perform_now)
        end
      end
    end
  end

  path '/api/v1/projects/{id}' do
    let(:user) { create(:user, :admin, :approved) }
    let(:id) { create(:project).id }

    get('Retrieves project details') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Get selected project details.'

      parameter name: :id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of project'

      response '200', 'Project found' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/project'

        run_test!
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '404', 'Project not found' do
        let(:Authorization) { authorization_header_for(user) }
        let(:id) { 'invalid-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
      end
    end
  end
end
